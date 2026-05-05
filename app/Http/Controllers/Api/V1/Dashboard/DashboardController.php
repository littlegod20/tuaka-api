<?php

namespace App\Http\Controllers\Api\V1\Dashboard;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\Invoice;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $tenantId = app('current_tenant')->id;

        // ─── Stat cards ───────────────────────────────────────────────

        $totalRevenue = Invoice::where('status', 'paid')
            ->where('type', 'invoice')
            ->sum('total');

        $outstanding = Invoice::whereIn('status', ['sent', 'viewed', 'overdue'])
            ->where('type', 'invoice')
            ->sum('total');

        $draftCount = Invoice::where('status', 'draft')
            ->count();

        $paidThisMonth = Invoice::where('status', 'paid')
            ->where('type', 'invoice')
            ->whereMonth('paid_at', now()->month)
            ->whereYear('paid_at', now()->year)
            ->sum('total');

        $overdueCount = Invoice::where('status', 'overdue')
            ->where('type', 'invoice')
            ->count();

        $clientCount = Client::count();

        // ─── Revenue last 6 months ────────────────────────────────────

        $revenueByMonth = Invoice::where('status', 'paid')
            ->where('type', 'invoice')
            ->where('paid_at', '>=', now()->subMonths(5)->startOfMonth())
            ->selectRaw("TO_CHAR(paid_at, 'YYYY-MM') as month, SUM(total) as revenue")
            ->groupBy('month')
            ->orderBy('month')
            ->get()
            ->keyBy('month');

        // Fill in missing months with 0
        $months = [];
        for ($i = 5; $i >= 0; $i--) {
            $key = now()->subMonths($i)->format('Y-m');
            $months[] = [
                'month'   => now()->subMonths($i)->format('M Y'),
                'revenue' => (int) ($revenueByMonth[$key]->revenue ?? 0),
            ];
        }

        // ─── Recent invoices ──────────────────────────────────────────

        $recentInvoices = Invoice::with('client')
            ->where('type', 'invoice')
            ->orderByDesc('created_at')
            ->limit(5)
            ->get()
            ->map(fn($inv) => [
                'id'         => $inv->id,
                'number'     => $inv->number,
                'status'     => $inv->status,
                'total'      => $inv->total,
                'due_date'   => $inv->due_date?->toDateString(),
                'created_at' => $inv->created_at->toDateString(),
                'client'     => [
                    'name' => $inv->client?->name,
                ],
            ]);

        return response()->json([
            'stats' => [
                'total_revenue'   => $totalRevenue,
                'outstanding'     => $outstanding,
                'draft_count'     => $draftCount,
                'paid_this_month' => $paidThisMonth,
                'overdue_count'   => $overdueCount,
                'client_count'    => $clientCount,
            ],
            'revenue_chart'   => $months,
            'recent_invoices' => $recentInvoices,
        ]);
    }
}