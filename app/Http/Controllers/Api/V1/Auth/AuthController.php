<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use App\Models\User;
use App\Support\TuakaLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Throwable;

class AuthController extends Controller
{
    // ─── Register (creates tenant + owner account) ────────────────────────

    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'business_name' => ['required', 'string', 'max:100'],
            'slug'          => ['required', 'string', 'max:50', 'unique:tenants,slug', 'regex:/^[a-z0-9\-]+$/'],
            'name'          => ['required', 'string', 'max:100'],
            'email'         => ['required', 'email', 'max:150'],
            'password'      => ['required', 'confirmed', Password::min(8)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Email must be unique within this tenant's workspace.
        // On registration the tenant doesn't exist yet, so we just
        // check globally to prevent duplicate owner accounts.
        $emailExists = User::where('email', $request->email)->exists();
        if ($emailExists) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => ['email' => ['This email is already registered.']],
            ], 422);
        }

        try {
            DB::beginTransaction();

            // 1. Create the tenant workspace
            $tenant = Tenant::create([
                'name'     => $request->business_name,
                'slug'     => $request->slug,
                'currency' => 'GHS',
                'timezone' => 'Africa/Accra',
                'is_active' => true,
            ]);

            // 2. Create the owner user — HasTenant trait will auto-stamp tenant_id
            app()->instance('current_tenant', $tenant);

            $user = User::create([
                'name'      => $request->name,
                'email'     => $request->email,
                'password'  => Hash::make($request->password),
                'role'      => 'owner',
                'tenant_id' => $tenant->id,
            ]);

            DB::commit();

            TuakaLog::tenantRegistered($tenant->slug, 'none');
            $token = JWTAuth::fromUser($user);

            return response()->json([
                'message' => 'Workspace created successfully.',
                'token'   => $token,
                'user'    => $this->userData($user),
                'tenant'  => $this->tenantData($tenant),
            ], 201);

        } catch (Throwable $e) {
            DB::rollBack();

            TuakaLog::workspaceRegistrationFailed($e->getMessage(), [
                'email' => $request->input('email'),
                'slug'  => $request->input('slug'),
            ]);

            return response()->json([
                'message' => 'Registration failed.',
                'debug'   => $e->getMessage(),
                'file'    => class_basename($e->getFile()),
                'line'    => $e->getLine(),
            ], 500);
        }
    }

    // ─── Login ────────────────────────────────────────────────────────────

    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // auth()->guard() is already scoped to the current tenant
        // because TenantScope is applied to the User model.
        $token = auth('api')->attempt([
            'email'    => $request->email,
            'password' => $request->password,
        ]);

        if (! $token) {
            $slug = $request->tenant()?->slug ?? 'unknown';
            TuakaLog::tenantUserLoginFailed($slug, $request->input('email', ''));

            return response()->json([
                'message' => 'Invalid credentials.',
            ], 401);
        }

        $user = auth('api')->user();
        TuakaLog::tenantUserLoginSuccess(
            $user->tenant->slug,
            (string) $user->id,
            $user->email
        );

        return response()->json([
            'token'  => $token,
            'user'   => $this->userData($user),
            'tenant' => $this->tenantData($user->tenant),
        ]);
    }

    // ─── Logout ───────────────────────────────────────────────────────────

    public function logout(): JsonResponse
    {
        $user = auth('api')->user();
        if ($user?->tenant) {
            TuakaLog::tenantUserLoggedOut($user->tenant->slug, (string) $user->id);
        }

        auth('api')->logout();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }

    // ─── Refresh token ────────────────────────────────────────────────────

    public function refresh(Request $request): JsonResponse
    {
        try {
            $token = auth('api')->refresh();
        } catch (Throwable $e) {
            $user = auth('api')->user();
            $tenant = $request->tenant();
            if ($user && $tenant) {
                TuakaLog::tenantUserTokenRefreshFailed($tenant->slug, (string) $user->id);
            }

            return response()->json([
                'message' => 'Token cannot be refreshed.',
            ], 401);
        }

        return response()->json([
            'token' => $token,
        ]);
    }

    // ─── Me ───────────────────────────────────────────────────────────────

    public function me(): JsonResponse
    {
        $user = auth('api')->user();

        return response()->json([
            'user'   => $this->userData($user),
            'tenant' => $this->tenantData($user->tenant),
        ]);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────

    private function userData(User $user): array
    {
        return [
            'id'         => $user->id,
            'name'       => $user->name,
            'email'      => $user->email,
            'role'       => $user->role,
            'created_at' => $user->created_at,
        ];
    }

    private function tenantData(Tenant $tenant): array
    {
        return [
            'id'       => $tenant->id,
            'name'     => $tenant->name,
            'slug'     => $tenant->slug,
            'currency' => $tenant->currency,
            'timezone' => $tenant->timezone,
        ];
    }
}