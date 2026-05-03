<?php

namespace App\Providers;

use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind('current_tenant', fn () => null);
    }

    public function boot(): void
    {
        // Add $request->tenant() helper
        Request::macro('tenant', function (): ?Tenant {
            return $this->get('_tenant');
        });
    }
}