<?php

namespace App\Providers;

use App\Models\Tenant;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
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

        // Rate limit auth endpoints
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(10)->by(
                $request->ip()
            );
        });

        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(120)->by(
                $request->user()?->id ?: $request->ip()
            );
        });
    }
}