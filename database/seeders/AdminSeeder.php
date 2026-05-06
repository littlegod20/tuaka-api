<?php

namespace Database\Seeders;

use App\Models\Admin;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        Admin::updateOrCreate(
            ['email' => 'admin@tuaka.app'],
            [
                'name'     => 'TuaKa Admin',
                'email'    => 'admin@tuaka.app',
                'password' => Hash::make('password'),
            ],
        );
    }
}