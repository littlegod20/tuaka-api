<?php

namespace App\Http\Middleware;

use App\Models\Tenant;
use App\Support\TuakaLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Log;

class ResolveTenant
{
    public function handle(Request $request, Closure $next): Response
    {
        $slug = $this->resolveTenantSlug($request);

        if (! $slug) {
            TuakaLog::tenantHeaderMissing();

            return response()->json([
                'message' => 'Tenant could not be identified.',
            ], 400);
        }

        $tenant = Tenant::where('slug', $slug)->first();
        Log::info('Tenant: ' . $tenant);

        if (! $tenant) {
            TuakaLog::workspaceNotFound($slug);

            return response()->json([
                'message' => 'Workspace not found.',
            ], 404);
        }

        // Bind into the service container — this is what
        // TenantScope reads on every Eloquent query
        app()->instance('current_tenant', $tenant);

        // Also attach to the request so controllers
        // can access it directly via $request->tenant()
        $request->merge(['_tenant' => $tenant]);

        return $next($request);
    }

    /**
     * Resolve the tenant slug from the request.
     *
     * Priority:
     * 1. X-Tenant header (set by Nginx in production)
     * 2. DEV_TENANT env variable (local development fallback)
     */
    private function resolveTenantSlug(Request $request): ?string
    {
        // Production — Nginx sets this from the subdomain
        $header = $request->header('X-Tenant');

        if ($header) {
            return strtolower(trim($header));
        }

        // Local development fallback
        // Set DEV_TENANT=acme in your .env
        if (app()->environment('local', 'testing')) {
            $devTenant = config('app.dev_tenant');
            if ($devTenant) {
                return strtolower($devTenant);
            }
        }

        return null;
    }
}