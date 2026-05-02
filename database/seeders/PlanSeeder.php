<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PlanSeeder extends Seeder
{
    public function run(): void
    {
        $plans = [
            [
                'id'            => Str::uuid(),
                'name'          => 'Free',
                'slug'          => 'free',
                'price_monthly' => 0,
                'invoice_limit' => 5,
                'features'      => json_encode([
                    'invoices_per_month' => 5,
                    'clients'            => 10,
                    'pdf_export'         => true,
                    'reminders'          => false,
                    'custom_branding'    => false,
                ]),
                'is_active'     => true,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'id'            => Str::uuid(),
                'name'          => 'Basic',
                'slug'          => 'basic',
                'price_monthly' => 9000,   // GHS 90.00 in pesewas
                'invoice_limit' => 50,
                'features'      => json_encode([
                    'invoices_per_month' => 50,
                    'clients'            => 100,
                    'pdf_export'         => true,
                    'reminders'          => true,
                    'custom_branding'    => false,
                ]),
                'is_active'     => true,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'id'            => Str::uuid(),
                'name'          => 'Pro',
                'slug'          => 'pro',
                'price_monthly' => 25000,  // GHS 250.00 in pesewas
                'invoice_limit' => -1,     // unlimited
                'features'      => json_encode([
                    'invoices_per_month' => -1,
                    'clients'            => -1,
                    'pdf_export'         => true,
                    'reminders'          => true,
                    'custom_branding'    => true,
                ]),
                'is_active'     => true,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
        ];

        DB::table('plans')->insert($plans);
    }
}