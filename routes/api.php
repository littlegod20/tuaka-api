<?php

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Invoice\InvoiceController;
use App\Http\Controllers\Api\V1\Client\ClientController;
use App\Http\Controllers\Api\V1\Product\ProductController;
use App\Http\Controllers\Api\V1\Billing\BillingController;
use App\Http\Controllers\Api\V1\Tenant\TeamController;
use App\Http\Controllers\Api\V1\Webhook\WebhookController;
use App\Http\Controllers\Api\V1\Auth\AdminAuthController;
use Illuminate\Support\Facades\Route;

// ─── Health check ─────────────────────────────────────────────────────────
Route::get('/health', fn () => response()->json(['status' => 'ok']));

// ─── Webhooks (public, no auth, signature-verified) ───────────────────────
Route::prefix('webhooks')->group(function () {
    Route::post('paystack', [WebhookController::class, 'handlePaystack']);
    Route::post('momo',     [WebhookController::class, 'handleMomo']);
});

// ─── Public invoice routes (no auth, token-based) ─────────────────────────
Route::prefix('inv')->group(function () {
    Route::get('{token}',      [InvoiceController::class, 'publicView']);
    Route::post('{token}/pay', [InvoiceController::class, 'publicPay']);
});

// ─── Admin routes (separate guard, no tenant scope) ───────────────────────
Route::prefix('v1/admin')->group(function () {
    Route::post('login', [AdminAuthController::class, 'login']);

    Route::middleware('auth:admin')->group(function () {
        Route::post('logout', [AdminAuthController::class, 'logout']);
        Route::get('dashboard', fn () => response()->json(['message' => 'admin ok']));
        // Admin tenant + plan routes added later
    });
});

// ─── Tenant API routes ─────────────────────────────────────────────────────
// Every route here runs through:
// 1. tenant     — resolves tenant from X-Tenant header
// 2. auth:api   — verifies JWT token
// 3. subscription — checks subscription is valid
Route::post('v1/register', [AuthController::class, 'register']);
Route::prefix('v1')
    ->middleware(['tenant'])
    ->group(function () {

        // Auth — no JWT needed yet (this is how you get the token)
        Route::post('login',    [AuthController::class, 'login']);

        // Protected — JWT required from here on
        Route::middleware(['auth:api', 'subscription'])
        ->group(function () {
            
                Route::get('me',       [AuthController::class, 'me']);
                Route::post('logout',  [AuthController::class, 'logout']);
                
                // Invoices and quotes
                Route::apiResource('invoices', InvoiceController::class);
                Route::post('invoices/{invoice}/send',       [InvoiceController::class, 'send']);
                Route::post('invoices/{invoice}/mark-paid',  [InvoiceController::class, 'markPaid']);
                Route::post('invoices/{invoice}/convert',    [InvoiceController::class, 'convert']);
                
                // Clients
                Route::apiResource('clients', ClientController::class);
                
                // Products
                Route::apiResource('products', ProductController::class);
                
                // Team
                Route::get('team',             [TeamController::class, 'index']);
                Route::post('team/invite',      [TeamController::class, 'invite']);
                Route::delete('team/{user}',    [TeamController::class, 'remove']);
                
                // Billing
                Route::get('plans',              [BillingController::class, 'plans']);
                Route::post('billing/subscribe', [BillingController::class, 'subscribe']);
                Route::post('billing/cancel',    [BillingController::class, 'cancel']);
                Route::get('billing/invoices',   [BillingController::class, 'invoices']);
            });
            Route::post('refresh', [AuthController::class, 'refresh']);
    });