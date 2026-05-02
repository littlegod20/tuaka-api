<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Bind current_tenant as null by default.
        // ResolveTenant middleware will override this
        // on every HTTP request.
        $this->app->bind('current_tenant', fn () => null);
    }

    public function boot(): void
    {
        //
    }
}