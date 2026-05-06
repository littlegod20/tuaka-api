<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Subscription;
use App\Models\Tenant;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        // ─── Tenant stats ──────────────────────────────────────────────
        $totalTenants  = Tenant::withoutGlobalScopes()->count();
        $newThisMonth  = Tenant::withoutGlobalScopes()
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        // ─── Subscription stats ────────────────────────────────────────
        $activeCount   = Subscription::withoutGlobalScopes()
            ->where('status', 'active')
            ->count();
        $trialingCount = Subscription::withoutGlobalScopes()
            ->where('status', 'trialing')
            ->where('trial_ends_at', '>', now())
            ->count();
        $cancelledCount = Subscription::withoutGlobalScopes()
            ->where('status', 'cancelled')
            ->count();

        // ─── MRR (active paid subscriptions) ──────────────────────────
        $mrr = Subscription::withoutGlobalScopes()
            ->where('status', 'active')
            ->join('plans', 'subscriptions.plan_id', '=', 'plans.id')
            ->sum('plans.price_monthly');

        // ─── Invoice stats ─────────────────────────────────────────────
        $totalInvoices = Invoice::withoutGlobalScopes()->count();
        $paidInvoices  = Invoice::withoutGlobalScopes()
            ->where('status', 'paid')
            ->count();
        $totalRevenue  = Invoice::withoutGlobalScopes()
            ->where('status', 'paid')
            ->sum('total');

        // ─── Signups last 6 months ─────────────────────────────────────
        $signupsByMonth = Tenant::withoutGlobalScopes()
            ->where('created_at', '>=', now()->subMonths(5)->startOfMonth())
            ->selectRaw("TO_CHAR(created_at, 'YYYY-MM') as month, COUNT(*) as count")
            ->groupBy('month')
            ->orderBy('month')
            ->get()
            ->keyBy('month');

        $signupChart = [];
        for ($i = 5; $i >= 0; $i--) {
            $key = now()->subMonths($i)->format('Y-m');
            $signupChart[] = [
                'month' => now()->subMonths($i)->format('M Y'),
                'count' => (int) ($signupsByMonth[$key]->count ?? 0),
            ];
        }

        // ─── Recent tenants ────────────────────────────────────────────
        $recentTenants = Tenant::withoutGlobalScopes()
            ->with(['subscription.plan'])
            ->orderByDesc('created_at')
            ->limit(8)
            ->get()
            ->map(fn($t) => [
                'id'         => $t->id,
                'name'       => $t->name,
                'slug'       => $t->slug,
                'created_at' => $t->created_at->toDateString(),
                'plan'       => $t->subscription?->plan?->name ?? 'Free',
                'status'     => $t->subscription?->status ?? 'free',
            ]);

        return response()->json([
            'stats' => [
                'total_tenants'   => $totalTenants,
                'new_this_month'  => $newThisMonth,
                'active_paid'     => $activeCount,
                'trialing'        => $trialingCount,
                'cancelled'       => $cancelledCount,
                'mrr'             => (int) $mrr,
                'total_invoices'  => $totalInvoices,
                'paid_invoices'   => $paidInvoices,
                'total_revenue'   => (int) $totalRevenue,
            ],
            'signup_chart'   => $signupChart,
            'recent_tenants' => $recentTenants,
        ]);
    }
}