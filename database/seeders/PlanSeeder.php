<?php

namespace Database\Seeders;

use App\Models\Plan;
use Illuminate\Database\Seeder;

class PlanSeeder extends Seeder
{
    public function run(): void
    {
        $plans = [
            [
                'name'          => 'Free',
                'slug'          => 'free',
                'price_monthly' => 0,
                'invoice_limit' => 5,
                'features'      => [
                    '5 invoices per month',
                    'PDF downloads',
                    'MoMo payments',
                    '1 user',
                ],
                'is_active' => true,
            ],
            [
                'name'          => 'Starter',
                'slug'          => 'starter',
                'price_monthly' => 3500, // GHS 35.00
                'invoice_limit' => -1, // unlimited invoices
                'features'      => [
                    'Unlimited invoices',
                    'PDF downloads',
                    'MoMo payments',
                    'Up to 3 team members',
                    'Email support',
                ],
                'is_active' => true,
            ],
            [
                'name'          => 'Growth',
                'slug'          => 'growth',
                'price_monthly' => 7500, // GHS 75.00
                'invoice_limit' => -1, // unlimited invoices
                'features'      => [
                    'Unlimited invoices',
                    'PDF downloads',
                    'MoMo payments',
                    'Up to 10 team members',
                    'Priority support',
                    'Custom invoice prefix',
                ],
                'is_active' => true,
            ],
        ];

        foreach ($plans as $plan) {
            Plan::updateOrCreate(['slug' => $plan['slug']], $plan);
        }
    }
}