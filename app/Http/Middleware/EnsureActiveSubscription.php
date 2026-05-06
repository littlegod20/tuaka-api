<?php

namespace App\Http\Middleware;

use App\Models\Plan;
use App\Models\Subscription;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveSubscription
{
    // Always accessible regardless of plan
    private array $except = [
        'api/v1/billing/*',
        'api/v1/logout',
        'api/v1/me',
        'api/v1/dashboard',
        'api/v1/invoices',
        'api/v1/clients',
        'api/v1/products',
    ];

    // Write actions blocked on free tier when limit reached
    private array $writeActions = [
        'api/v1/invoices'  => ['POST'],
        'api/v1/clients'   => ['POST'],
        'api/v1/products'  => ['POST'],
        'api/v1/invoices/*/send' => ['POST'],
    ];

    public function handle(Request $request, Closure $next): Response
    {
        $tenant = app('current_tenant');

        if (! $tenant) {
            return $next($request);
        }

        // Always allow excepted routes
        foreach ($this->except as $pattern) {
            if ($request->is($pattern)) {
                return $next($request);
            }
        }

        $subscription = $tenant->subscription;
        $plan         = $this->resolvePlan($subscription);

        // Attach plan info to request for controllers to use
        $request->merge(['_plan' => $plan, '_subscription' => $subscription]);

        // Trial active — full access
        if ($subscription?->isTrialing()) {
            $this->attachHeaders($request, $subscription, $plan);
            return $next($request);
        }

        // Paid plan active — full access
        if ($subscription?->isActive()) {
            return $next($request);
        }

        // Grace period — allow through with header
        if ($subscription?->isInGracePeriod()) {
            $request->headers->set('X-Subscription-Grace', 'true');
            return $next($request);
        }

        // Free tier or expired — enforce invoice limit on writes
        if ($request->isMethod('POST') && $request->is('api/v1/invoices')) {
            $usedThisMonth = \App\Models\Invoice::whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->count();

            if (! $plan->hasUnlimitedInvoices() && $usedThisMonth >= $plan->invoice_limit) {
                return response()->json([
                    'message'       => "You've reached your {$plan->invoice_limit} invoice limit for this month.",
                    'status'        => 'limit_reached',
                    'upgrade_url'   => '/billing',
                    'limit'         => $plan->invoice_limit,
                    'used'          => $usedThisMonth,
                ], 402);
            }
        }

        return $next($request);
    }

    private function resolvePlan(?Subscription $subscription): Plan
    {
        // Trialing or active paid — use subscription's plan
        if ($subscription && ($subscription->isTrialing() || $subscription->isActive())) {
            return $subscription->plan;
        }

        // Expired, cancelled, or no subscription — free plan
        return Plan::where('slug', 'free')->first()
            ?? new Plan(['invoice_limit' => 5, 'price_monthly' => 0]);
    }

    private function attachHeaders(Request $request, Subscription $subscription, Plan $plan): void
    {
        if ($subscription->isTrialing() && $subscription->trial_ends_at) {
            $daysLeft = (int) now()->diffInDays($subscription->trial_ends_at, false);
            if ($daysLeft <= 3) {
                $request->headers->set('X-Trial-Ending', (string) $daysLeft);
            }
        }
    }
}