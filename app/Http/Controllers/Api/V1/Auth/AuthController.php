<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Mail\VerifyEmailMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Models\Plan;
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

            // Start 14-day Starter trial
            $starterPlan = \App\Models\Plan::where('slug', 'starter')->first();
            if ($starterPlan) {
                \App\Models\Subscription::create([
                    'tenant_id'            => $tenant->id,
                    'plan_id'              => $starterPlan->id,
                    'status'               => 'trialing',
                    'trial_ends_at'        => now()->addDays(14),
                    'current_period_start' => now(),
                    'current_period_end'   => now()->addDays(14),
                ]);
            }

            TuakaLog::tenantRegistered($tenant->slug, 'none');
            $token = JWTAuth::fromUser($user);

            // Send verification email
            $token = Str::random(64);
            $user->update(['email_verification_token' => $token]);
            $url = config('app.frontend_url') . '/verify-email?token=' . $token . '&email=' . urlencode($user->email);
            Mail::to($user->email)->queue(new VerifyEmailMail($user, $url));

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

        if (class_exists(\Sentry\SentrySdk::class)) {
            \Sentry\configureScope(function (\Sentry\State\Scope $scope) use ($user): void {
                $scope->setUser([
                    'id'    => $user->id,
                    'email' => $user->email,
                ]);
            });
        }

        $tenant = $user->tenant;
        $subscription = $tenant->subscription?->load('plan');

        $usedThisMonth = \App\Models\Invoice::whereMonth('created_at', now()->month)
        ->whereYear('created_at', now()->year)
        ->count();

        $plan  = $subscription?->plan ?? \App\Models\Plan::where('slug', 'free')->first();
        $limit = $plan?->invoice_limit ?? 5;

        $clientCount  = \App\Models\Client::count();
        $productCount = \App\Models\Product::count();
        $invoiceCount = \App\Models\Invoice::count();
        $sentCount    = \App\Models\Invoice::whereNotNull('sent_at')->count();


        return response()->json([
            'user'         => $this->userData($user),
            'tenant'       => $this->tenantData($tenant),
            'subscription' => $subscription ? $this->subscriptionData($subscription) : null,
            'usage'        => [
                'invoices_this_month' => $usedThisMonth,
                'invoice_limit'       => $limit,
                'limit_reached'       => $limit !== -1 && $usedThisMonth >= $limit,
            ],
            'onboarding' => [
                'has_client'  => $clientCount > 0,
                'has_product' => $productCount > 0,
                'has_invoice' => $invoiceCount > 0,
                'has_sent'    => $sentCount > 0,
                'complete'    => $clientCount > 0 && $invoiceCount > 0 && $sentCount > 0,
            ],
        ]);
    }



    private function subscriptionData(\App\Models\Subscription $sub): array
    {
        return [
            'status'          => $sub->status,
            'is_trialing'     => $sub->isTrialing(),
            'is_active'       => $sub->isActive(),
            'trial_ends_at'   => $sub->trial_ends_at?->toDateString(),
            'period_ends_at'  => $sub->current_period_end?->toDateString(),
            'plan'            => $sub->plan ? [
                'name'          => $sub->plan->name,
                'slug'          => $sub->plan->slug,
                'price_monthly' => $sub->plan->price_monthly,
                'invoice_limit' => $sub->plan->invoice_limit,
                'features'      => Plan::ensureFeatureList($sub->plan->features),
            ] : null,
        ];
    }


    // ─── Helpers ──────────────────────────────────────────────────────────

    private function userData(User $user): array
    {
        return [
            'id'                  => $user->id,
            'name'                => $user->name,
            'email'               => $user->email,
            'role'                => $user->role,
            'email_verified_at'   => $user->email_verified_at,
            'created_at'          => $user->created_at,
        ];
    }

    private function tenantData(Tenant $tenant): array
    {
        return [
            'id'             => $tenant->id,
            'name'           => $tenant->name,
            'slug'           => $tenant->slug,
            'currency'       => $tenant->currency,
            'timezone'       => $tenant->timezone,
            'invoice_prefix' => $tenant->invoice_prefix,
            'address'        => $tenant->address,
            'phone'          => $tenant->phone,
            'website'        => $tenant->website,
        ];
    }
}