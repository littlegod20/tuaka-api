<?php

namespace App\Http\Middleware;

use App\Support\TuakaLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveSubscription
{
    /**
     * Routes that are always allowed regardless of
     * subscription status — billing routes must be
     * accessible so tenants can re-subscribe.
     */
    private array $except = [
        'api/v1/billing/*',
        'api/v1/logout',
        'api/v1/me',
    ];

    public function handle(Request $request, Closure $next): Response
    {
        // Skip check for excepted routes
        foreach ($this->except as $pattern) {
            if ($request->is($pattern)) {
                return $next($request);
            }
        }

        $tenant = $request->tenant();

        if (! $tenant) {
            return $next($request);
        }

        $subscription = $tenant->subscription;

        // No subscription at all — only free plan tenants
        // would reach here, allow them through
        if (! $subscription) {
            return $next($request);
        }

        // Active or trialing — all good
        if ($subscription->isActive() || $subscription->isTrialing()) {
            return $next($request);
        }

        // Grace period — allow through but flag it
        // Frontend can show a warning banner
        if ($subscription->isInGracePeriod()) {
            $request->headers->set(
                'X-Subscription-Grace',
                $subscription->current_period_end?->diffInDays(now()) . ' days remaining'
            );
            return $next($request);
        }

        // Cancelled or expired — block access
        TuakaLog::subscriptionAccessDenied(
            $tenant->slug,
            (string) $subscription->status
        );

        return response()->json([
            'message'       => 'Your subscription has ended.',
            'status'        => 'subscription_ended',
            'renew_url'     => '/billing',
        ], 402); // 402 Payment Required
    }
}