<?php

namespace App\Console\Commands;

use App\Models\Subscription;
use App\Models\Plan;
use Illuminate\Console\Command;

class ProcessExpiredSubscriptions extends Command
{
    protected $signature   = 'subscriptions:process-expired';
    protected $description = 'Move expired trials and lapsed paid plans to free tier';

    public function handle(): void
    {
        $freePlan = Plan::where('slug', 'free')->first();
        if (! $freePlan) {
            $this->error('Free plan not found. Run PlanSeeder first.');
            return;
        }

        // Expired trials → free
        $trials = Subscription::withoutGlobalScopes()
            ->where('status', 'trialing')
            ->where('trial_ends_at', '<', now())
            ->get();

        foreach ($trials as $sub) {
            $sub->update([
                'status'  => 'cancelled',
                'plan_id' => $freePlan->id,
            ]);
            $this->line("Trial expired for tenant {$sub->tenant_id}");
        }

        // Lapsed paid subscriptions → free
        $lapsed = Subscription::withoutGlobalScopes()
            ->where('status', 'active')
            ->where('current_period_end', '<', now())
            ->get();

        foreach ($lapsed as $sub) {
            $sub->update([
                'status'  => 'cancelled',
                'plan_id' => $freePlan->id,
            ]);
            $this->line("Subscription lapsed for tenant {$sub->tenant_id}");
        }

        $total = $trials->count() + $lapsed->count();
        $this->info("Processed {$total} expired subscription(s).");
    }
}