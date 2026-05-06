<?php

namespace App\Http\Controllers\Api\V1\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Invite;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class InviteController extends Controller
{
    // ─── Get invite details (public) ──────────────────────────────────

    public function show(string $token): JsonResponse
    {
        $invite = Invite::with(['tenant'])
            ->where('token', $token)
            ->first();

        if (! $invite) {
            return response()->json([
                'message' => 'Invalid invitation link.',
            ], 404);
        }

        if ($invite->isExpired()) {
            return response()->json([
                'message' => 'This invitation has expired.',
                'expired' => true,
            ], 410);
        }

        if ($invite->accepted_at) {
            return response()->json([
                'message'  => 'This invitation has already been accepted.',
                'accepted' => true,
            ], 409);
        }

        return response()->json([
            'email'       => $invite->email,
            'role'        => $invite->role,
            'tenant_name' => $invite->tenant->name,
            'expires_at'  => $invite->expires_at,
        ]);
    }

    // ─── Accept invite ────────────────────────────────────────────────

    public function accept(Request $request, string $token): JsonResponse
    {
        $invite = Invite::with(['tenant'])
            ->where('token', $token)
            ->first();

        if (! $invite) {
            return response()->json(['message' => 'Invalid invitation.'], 404);
        }

        if ($invite->isExpired()) {
            return response()->json(['message' => 'This invitation has expired.'], 410);
        }

        if ($invite->accepted_at) {
            return response()->json(['message' => 'Invitation already accepted.'], 409);
        }

        $validator = Validator::make($request->all(), [
            'name'     => ['required', 'string', 'max:100'],
            'password' => ['required', Password::min(8)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Check if email already exists in this tenant
        $existing = User::where('email', $invite->email)->first();
        if ($existing) {
            return response()->json([
                'message' => 'An account with this email already exists.',
            ], 409);
        }

        // Bind tenant so HasTenant trait works
        app()->instance('current_tenant', $invite->tenant);

        $user = User::create([
            'tenant_id'  => $invite->tenant_id,
            'name'       => $request->name,
            'email'      => $invite->email,
            'password'   => Hash::make($request->password),
            'role'       => $invite->role,
            'is_active'  => true,
            'invited_at' => now(),
        ]);

        $invite->update(['accepted_at' => now()]);

        $jwtToken = JWTAuth::fromUser($user);

        return response()->json([
            'message' => 'Welcome to ' . $invite->tenant->name . '!',
            'token'   => $jwtToken,
            'user'    => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
                'role'  => $user->role,
            ],
            'tenant'  => [
                'id'   => $invite->tenant->id,
                'name' => $invite->tenant->name,
                'slug' => $invite->tenant->slug,
            ],
        ], 201);
    }
}