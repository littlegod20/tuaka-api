<?php

use App\Http\Middleware\EnsureActiveSubscription;
use App\Http\Middleware\ResolveTenant;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use App\Http\Middleware\EnsureRole;
use Sentry\Laravel\Integration;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'tenant'       => ResolveTenant::class,
            'subscription' => EnsureActiveSubscription::class,
            'role'         => EnsureRole::class,
        ]);

          // Tell Laravel's Authenticate middleware to return null
        // (no redirect) for all API requests — this prevents the
        // "Route [login] not defined" crash
        $middleware->redirectGuestsTo(fn (Request $request) => null);
        $middleware->append(\App\Http\Middleware\SecurityHeaders::class);

    })
    ->withExceptions(function (Exceptions $exceptions): void {
        Integration::handles($exceptions);
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'message' => 'Unauthenticated.',
                ], 401);
            }
        });
    })->create();
