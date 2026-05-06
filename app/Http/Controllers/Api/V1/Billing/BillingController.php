<?php

namespace App\Http\Controllers\Api\V1\Billing;

use App\Http\Controllers\Controller;
use App\Models\Plan;
use App\Models\Subscription;
use App\Services\PaystackService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BillingController extends Controller
{
    public function __construct(private PaystackService $paystack) {}

    // ─── List plans ───────────────────────────────────────────────────

    public function plans(): JsonResponse
    {
        $plans = Plan::where('is_active', true)
            ->orderBy('price_monthly')
            ->get();

        return response()->json(
            $plans->map(fn (Plan $plan) => array_merge($plan->toArray(), [
                'features' => Plan::ensureFeatureList($plan->features),
            ])),
        );
    }

    // ─── Current subscription ─────────────────────────────────────────

    public function current(): JsonResponse
    {
        $tenant       = app('current_tenant');
        $subscription = $tenant->subscription?->load('plan');

        if (! $subscription) {
            $freePlan = Plan::where('slug', 'free')->first();
            $planPayload = $freePlan
                ? array_merge($freePlan->toArray(), [
                    'features' => Plan::ensureFeatureList($freePlan->features),
                ])
                : null;

            return response()->json([
                'plan'         => $planPayload,
                'status'       => 'free',
                'is_trialing'  => false,
                'is_active'    => false,
            ]);
        }

        $planModel = $subscription->plan;
        $planPayload = $planModel
            ? array_merge($planModel->toArray(), [
                'features' => Plan::ensureFeatureList($planModel->features),
            ])
            : null;

        return response()->json([
            'plan'            => $planPayload,
            'status'          => $subscription->status,
            'is_trialing'     => $subscription->isTrialing(),
            'is_active'       => $subscription->isActive(),
            'trial_ends_at'   => $subscription->trial_ends_at?->toDateString(),
            'period_ends_at'  => $subscription->current_period_end?->toDateString(),
            'cancelled_at'    => $subscription->cancelled_at?->toDateString(),
        ]);
    }

    // ─── Initialize Paystack payment for subscription ─────────────────

    public function subscribe(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'plan_slug' => ['required', 'string', 'exists:plans,slug'],
            'email'     => ['required', 'email'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $plan = Plan::where('slug', $request->plan_slug)->firstOrFail();

        if ($plan->isFree()) {
            return response()->json([
                'message' => 'Cannot subscribe to the free plan.',
            ], 422);
        }

        $tenant    = app('current_tenant');
        $reference = PaystackService::generateReference($tenant->id);

        // Initialize Paystack transaction
        $result = $this->paystack->initializeTransaction(
            email:     $request->email,
            amount:    $plan->price_monthly,
            reference: $reference,
            metadata:  [
                'tenant_id' => $tenant->id,
                'plan_slug' => $plan->slug,
                'plan_id'   => $plan->id,
            ],
            callbackUrl: config('app.frontend_url') . '/billing/callback',
        );

        if (! ($result['status'] ?? false)) {
            return response()->json([
                'message' => 'Could not initialize payment.',
            ], 422);
        }

        return response()->json([
            'authorization_url' => $result['data']['authorization_url'],
            'reference'         => $reference,
        ]);
    }

    // ─── Verify payment after Paystack redirect ────────────────────────

    public function verifyPayment(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reference' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Reference required.',
            ], 422);
        }

        $result = $this->paystack->verifyTransaction($request->reference);

        if (
            ! ($result['status'] ?? false) ||
            ($result['data']['status'] ?? '') !== 'success'
        ) {
            return response()->json([
                'message' => 'Payment not confirmed.',
            ], 422);
        }

        $data     = $result['data'];
        $meta     = $data['metadata'] ?? [];
        $tenant   = app('current_tenant');
        $plan     = Plan::find($meta['plan_id'] ?? '');

        if (! $plan) {
            return response()->json(['message' => 'Plan not found.'], 422);
        }

        // Create or update subscription
        $subscription = Subscription::withoutGlobalScopes()
            ->where('tenant_id', $tenant->id)
            ->latest()
            ->first();

        $periodStart = now();
        $periodEnd   = now()->addMonth();

        if ($subscription) {
            $subscription->update([
                'plan_id'              => $plan->id,
                'status'               => 'active',
                'paystack_ref'         => $data['reference'],
                'current_period_start' => $periodStart,
                'current_period_end'   => $periodEnd,
                'cancelled_at'         => null,
            ]);
        } else {
            $subscription = Subscription::create([
                'tenant_id'            => $tenant->id,
                'plan_id'              => $plan->id,
                'status'               => 'active',
                'paystack_ref'         => $data['reference'],
                'current_period_start' => $periodStart,
                'current_period_end'   => $periodEnd,
            ]);
        }

        return response()->json([
            'message'      => 'Subscription activated.',
            'subscription' => $subscription->load('plan'),
        ]);
    }

    // ─── Cancel subscription ──────────────────────────────────────────

    public function cancel(): JsonResponse
    {
        $tenant       = app('current_tenant');
        $subscription = $tenant->subscription;

        if (! $subscription || ! $subscription->isActive()) {
            return response()->json([
                'message' => 'No active subscription to cancel.',
            ], 422);
        }

        $subscription->update([
            'status'       => 'cancelled',
            'cancelled_at' => now(),
        ]);

        return response()->json([
            'message'      => 'Subscription cancelled. You keep access until the end of the billing period.',
            'period_ends_at' => $subscription->current_period_end?->toDateString(),
        ]);
    }
}