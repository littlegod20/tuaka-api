<?php

namespace App\Http\Controllers\Api\V1\Tenant;

use App\Http\Controllers\Controller;
use App\Mail\InviteMail;
use App\Models\Invite;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class TeamController extends Controller
{
    // ─── List team members ────────────────────────────────────────────

    public function index(): JsonResponse
    {
        $tenant = app('current_tenant');
        $users = User::where('tenant_id', $tenant->id)
            ->orderBy('name')
            ->get()
            ->map(fn($u) => [
            'id'         => $u->id,
            'name'       => $u->name,
            'email'      => $u->email,
            'role'       => $u->role,
            'is_active'  => $u->is_active,
            'invited_at' => $u->invited_at,
            'created_at' => $u->created_at,
        ]);

        $pendingInvites = Invite::with('invitedBy')
            ->where('tenant_id', $tenant->id)
            ->where('accepted_at', null)
            ->where('expires_at', '>', now())
            ->get()
            ->map(fn($i) => [
                'id'          => $i->id,
                'email'       => $i->email,
                'role'        => $i->role,
                'invited_by'  => $i->invitedBy?->name ?? 'Unknown',
                'expires_at'  => $i->expires_at,
                'is_pending'  => true,
            ]);

        return response()->json([
            'members' => $users,
            'pending' => $pendingInvites,
        ]);
    }

    // ─── Send invite ──────────────────────────────────────────────────

    public function invite(Request $request): JsonResponse
    {
        $tenant = app('current_tenant');
        $actor = auth('api')->user();

        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'role'  => ['required', 'in:admin,member'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Admins can only invite members
        if ($actor->role === 'admin' && $request->role === 'admin') {
            return response()->json([
                'message' => 'Admins can only invite members.',
            ], 403);
        }

        // Check if user already exists in this tenant
        $exists = User::where('tenant_id', $tenant->id)
            ->where('email', $request->email)
            ->exists();
        if ($exists) {
            return response()->json([
                'message' => 'This email is already a member of your workspace.',
            ], 409);
        }

        // Delete any expired invite for this email
        Invite::where('email', $request->email)
            ->where('tenant_id', $tenant->id)
            ->delete();

        $invite = Invite::create([
            'tenant_id'  => $tenant->id,
            'invited_by' => $actor->id,
            'email'      => $request->email,
            'role'       => $request->role,
            'token'      => Str::random(64),
            'expires_at' => now()->addHours(48),
        ]);

        $url = config('app.frontend_url')
            . '/invite/accept?token=' . $invite->token;

        Mail::to($invite->email)
            ->queue(new InviteMail($invite->load(['tenant', 'invitedBy']), $url));

        return response()->json([
            'message' => 'Invitation sent.',
            'invite'  => [
                'id'         => $invite->id,
                'email'      => $invite->email,
                'role'       => $invite->role,
                'expires_at' => $invite->expires_at,
            ],
        ], 201);
    }

    // ─── Update role ──────────────────────────────────────────────────

    public function updateRole(Request $request, User $user): JsonResponse
    {
        $actor = auth('api')->user();

        $validator = Validator::make($request->all(), [
            'role' => ['required', 'in:admin,member'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Cannot change owner's role
        if ($user->role === 'owner') {
            return response()->json([
                'message' => 'Cannot change the owner\'s role.',
            ], 403);
        }

        // Cannot change own role
        if ($user->id === $actor->id) {
            return response()->json([
                'message' => 'Cannot change your own role.',
            ], 403);
        }

        $user->update(['role' => $request->role]);

        return response()->json([
            'message' => 'Role updated.',
            'user'    => ['id' => $user->id, 'role' => $user->role],
        ]);
    }

    // ─── Remove member ────────────────────────────────────────────────

    public function remove(User $user): JsonResponse
    {
        $actor = auth('api')->user();

        // Cannot remove the owner
        if ($user->role === 'owner') {
            return response()->json([
                'message' => 'Cannot remove the workspace owner.',
            ], 403);
        }

        // Admins cannot remove other admins
        if ($actor->role === 'admin' && $user->role === 'admin') {
            return response()->json([
                'message' => 'Admins cannot remove other admins.',
            ], 403);
        }

        // Cannot remove yourself
        if ($user->id === $actor->id) {
            return response()->json([
                'message' => 'Cannot remove yourself.',
            ], 403);
        }

        $user->delete();

        return response()->json(null, 204);
    }

    // ─── Revoke pending invite ────────────────────────────────────────

    public function revokeInvite(Invite $invite): JsonResponse
    {
        $actor = auth('api')->user();

        // Admins can only revoke invites they sent
        if ($actor->role === 'admin' && $invite->invited_by !== $actor->id) {
            return response()->json([
                'message' => 'You can only revoke invites you sent.',
            ], 403);
        }

        $invite->delete();

        return response()->json(null, 204);
    }

    // ─── Transfer ownership ───────────────────────────────────────────

    public function transferOwnership(Request $request): JsonResponse
    {
        $actor = auth('api')->user();

        if ($actor->role !== 'owner') {
            return response()->json([
                'message' => 'Only the owner can transfer ownership.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'user_id' => ['required', 'uuid'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $newOwner = User::findOrFail($request->user_id);

        if ($newOwner->id === $actor->id) {
            return response()->json([
                'message' => 'You are already the owner.',
            ], 422);
        }

        // Transfer
        $actor->update(['role' => 'admin']);
        $newOwner->update(['role' => 'owner']);

        return response()->json([
            'message' => 'Ownership transferred successfully.',
        ]);
    }
}