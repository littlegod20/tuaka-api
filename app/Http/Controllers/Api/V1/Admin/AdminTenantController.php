<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Plan;
use App\Models\Subscription;
use App\Models\Tenant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminTenantController extends Controller
{
    // ─── List all tenants ─────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $query = Tenant::withoutGlobalScopes()
            ->with(['subscription.plan'])
            ->orderByDesc('created_at');

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('slug', 'ilike', "%{$search}%");
            });
        }

        if ($status = $request->query('status')) {
            $query->whereHas('subscription', fn($q) =>
                $q->where('status', $status)
            );
        }

        $tenants = $query->paginate(20);

        return response()->json([
            'data' => collect($tenants->items())->map(fn($t) => [
                'id'         => $t->id,
                'name'       => $t->name,
                'slug'       => $t->slug,
                'currency'   => $t->currency,
                'created_at' => $t->created_at->toDateString(),
                'plan'       => $t->subscription?->plan?->name ?? 'Free',
                'plan_slug'  => $t->subscription?->plan?->slug ?? 'free',
                'sub_status' => $t->subscription?->status ?? 'free',
                'trial_ends' => $t->subscription?->trial_ends_at?->toDateString(),
                'period_ends'=> $t->subscription?->current_period_end?->toDateString(),
            ]),
            'meta' => [
                'current_page' => $tenants->currentPage(),
                'last_page'    => $tenants->lastPage(),
                'per_page'     => $tenants->perPage(),
                'total'        => $tenants->total(),
            ],
        ]);
    }

    // ─── Show single tenant ───────────────────────────────────────────

    public function show(string $id): JsonResponse
    {
        $tenant = Tenant::withoutGlobalScopes()
            ->with(['subscription.plan', 'users'])
            ->findOrFail($id);

        $invoiceCount = \App\Models\Invoice::withoutGlobalScopes()
            ->where('tenant_id', $id)
            ->count();

        $paidRevenue = \App\Models\Invoice::withoutGlobalScopes()
            ->where('tenant_id', $id)
            ->where('status', 'paid')
            ->sum('total');

        return response()->json([
            'id'           => $tenant->id,
            'name'         => $tenant->name,
            'slug'         => $tenant->slug,
            'currency'     => $tenant->currency,
            'created_at'   => $tenant->created_at->toDateString(),
            'plan'         => $tenant->subscription?->plan?->name ?? 'Free',
            'plan_slug'    => $tenant->subscription?->plan?->slug ?? 'free',
            'sub_status'   => $tenant->subscription?->status ?? 'free',
            'trial_ends'   => $tenant->subscription?->trial_ends_at?->toDateString(),
            'period_ends'  => $tenant->subscription?->current_period_end?->toDateString(),
            'member_count' => $tenant->users->count(),
            'invoice_count'=> $invoiceCount,
            'paid_revenue' => (int) $paidRevenue,
        ]);
    }

    // ─── Manually activate a subscription ────────────────────────────

    public function activate(Request $request, string $id): JsonResponse
    {
        $tenant = Tenant::withoutGlobalScopes()->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'plan_slug' => ['required', 'string', 'exists:plans,slug'],
            'months'    => ['sometimes', 'integer', 'min:1', 'max:24'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $plan   = Plan::where('slug', $request->plan_slug)->firstOrFail();
        $months = $request->input('months', 1);

        $subscription = Subscription::withoutGlobalScopes()
            ->where('tenant_id', $tenant->id)
            ->latest()
            ->first();

        if ($subscription) {
            $subscription->update([
                'plan_id'              => $plan->id,
                'status'               => 'active',
                'current_period_start' => now(),
                'current_period_end'   => now()->addMonths($months),
                'cancelled_at'         => null,
            ]);
        } else {
            Subscription::create([
                'tenant_id'            => $tenant->id,
                'plan_id'              => $plan->id,
                'status'               => 'active',
                'current_period_start' => now(),
                'current_period_end'   => now()->addMonths($months),
            ]);
        }

        return response()->json([
            'message' => "Subscription activated on {$plan->name} plan for {$months} month(s).",
        ]);
    }

    // ─── Deactivate / revert to free ──────────────────────────────────

    public function deactivate(string $id): JsonResponse
    {
        $tenant = Tenant::withoutGlobalScopes()->findOrFail($id);

        $freePlan = Plan::where('slug', 'free')->firstOrFail();

        $subscription = Subscription::withoutGlobalScopes()
            ->where('tenant_id', $tenant->id)
            ->latest()
            ->first();

        if ($subscription) {
            $subscription->update([
                'plan_id'      => $freePlan->id,
                'status'       => 'cancelled',
                'cancelled_at' => now(),
            ]);
        }

        return response()->json([
            'message' => 'Tenant moved to free plan.',
        ]);
    }
}