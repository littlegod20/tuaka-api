<?php

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Invoice\InvoiceController;
use App\Http\Controllers\Api\V1\Client\ClientController;
use App\Http\Controllers\Api\V1\Product\ProductController;
use App\Http\Controllers\Api\V1\Billing\BillingController;
use App\Http\Controllers\Api\V1\Tenant\TeamController;
use App\Http\Controllers\Api\V1\Tenant\TenantController;
use App\Http\Controllers\Api\V1\Webhook\WebhookController;
use App\Http\Controllers\Api\V1\Auth\AdminAuthController;
use App\Http\Controllers\Api\V1\Auth\EmailVerificationController;
use App\Http\Controllers\Api\V1\Auth\PasswordResetController;
use App\Http\Controllers\Api\V1\Payment\PaymentController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\Dashboard\DashboardController;
use App\Http\Controllers\Api\V1\Tenant\InviteController;

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
    Route::get('{token}/download',  [InvoiceController::class,  'downloadPublic']);
    Route::post('{token}/pay', [PaymentController::class, 'initiate']);
    Route::get('{token}/payment-status/{reference}', [PaymentController::class, 'status']);
});

// ─── Password reset (public, no tenant needed) ────────────────────────────
Route::prefix('v1')->group(function () {
    Route::post('forgot-password', [PasswordResetController::class, 'sendLink'])->middleware('throttle:auth');
    Route::post('reset-password',  [PasswordResetController::class, 'reset'])->middleware('throttle:auth');
});

// ─── Email verification (public token endpoint, no auth) ──────────────────
Route::get('v1/verify-email', [EmailVerificationController::class, 'verify']);


Route::prefix('v1/invite')->group(function () {
    Route::get('{token}',         [InviteController::class, 'show']);
    Route::post('{token}/accept', [InviteController::class, 'accept']);
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
Route::post('v1/register', [AuthController::class, 'register'])->middleware('throttle:auth');

Route::prefix('v1')
    ->middleware(['tenant'])
    ->group(function () {
        
        // Auth — no JWT needed yet (this is how you get the token)
        Route::post('login',    [AuthController::class, 'login'])->middleware('throttle:auth');

        // Protected — JWT required from here on
        Route::middleware(['auth:api', 'subscription'])
        ->group(function () {

                Route::get('me',       [AuthController::class, 'me']);
                Route::post('logout',  [AuthController::class, 'logout']);

                Route::post('email/resend', [EmailVerificationController::class, 'resend']);

                // Dashboard
                Route::get('dashboard', DashboardController::class);
               
                // Tenant
                Route::get('tenant',       [TenantController::class, 'show']);
                Route::put('tenant',       [TenantController::class, 'update']);

                // Invoices and quotes
                Route::apiResource('invoices', InvoiceController::class);
                Route::post('invoices/{invoice}/send',       [InvoiceController::class, 'send']);
                Route::post('invoices/{invoice}/mark-paid',  [InvoiceController::class, 'markPaid']);
                Route::post('invoices/{invoice}/convert',    [InvoiceController::class, 'convert']);
                Route::get('invoices/{invoice}/download', [InvoiceController::class, 'download']);


                // Clients (bulk route must be registered before apiResource)
                Route::post('clients/bulk-destroy', [ClientController::class, 'bulkDestroy']);
                Route::apiResource('clients', ClientController::class);
                
                // Products (bulk route must be registered before apiResource)
                Route::post('products/bulk-destroy', [ProductController::class, 'bulkDestroy']);
                Route::apiResource('products', ProductController::class);
                
                // Team
                Route::prefix('team')->group(function () {
                    Route::get('/',                  [TeamController::class, 'index']);
                
                    // Owner + admin only
                    Route::middleware('role:owner,admin')->group(function () {
                        Route::post('invite',            [TeamController::class, 'invite']);
                        Route::delete('invite/{invite}', [TeamController::class, 'revokeInvite']);
                        Route::delete('{user}',          [TeamController::class, 'remove']);
                    });
                
                    // Owner only
                    Route::middleware('role:owner')->group(function () {
                        Route::patch('{user}/role',      [TeamController::class, 'updateRole']);
                        Route::post('transfer',          [TeamController::class, 'transferOwnership']);
                    });
                });
                
                // Billing
                Route::prefix('billing')->group(function () {
                    Route::get('plans',          [BillingController::class, 'plans']);
                    Route::get('current',        [BillingController::class, 'current']);
                    Route::post('subscribe',     [BillingController::class, 'subscribe']);
                    Route::post('verify',        [BillingController::class, 'verifyPayment']);
                    Route::post('cancel',        [BillingController::class, 'cancel']);
                });
            });
            Route::post('refresh', [AuthController::class, 'refresh']);
    });