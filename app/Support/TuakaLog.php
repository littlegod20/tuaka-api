<?php

namespace App\Support;

use Illuminate\Support\Facades\Log;

class TuakaLog
{
    // ─── Payment logs ─────────────────────────────────────────────────

    public static function paymentReceived(
        string $provider,
        string $ref,
        int $amount,
        string $tenantSlug
    ): void {
        Log::channel('payments')->info('Payment received', [
            'provider'   => $provider,
            'ref'        => $ref,
            'amount'     => $amount,
            'tenant'     => $tenantSlug,
            'timestamp'  => now()->toIso8601String(),
        ]);
    }

    public static function paymentFailed(
        string $provider,
        string $ref,
        string $reason,
        string $tenantSlug
    ): void {
        Log::channel('payments')->error('Payment failed', [
            'provider'  => $provider,
            'ref'       => $ref,
            'reason'    => $reason,
            'tenant'    => $tenantSlug,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function webhookReceived(
        string $provider,
        string $event,
        string $ref
    ): void {
        Log::channel('payments')->info('Webhook received', [
            'provider'  => $provider,
            'event'     => $event,
            'ref'       => $ref,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function webhookDuplicate(
        string $provider,
        string $ref
    ): void {
        Log::channel('payments')->warning('Duplicate webhook skipped', [
            'provider'  => $provider,
            'ref'       => $ref,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    // ─── Tenant logs ──────────────────────────────────────────────────

    public static function tenantRegistered(string $slug, string $plan): void
    {
        Log::channel('tenants')->info('Tenant registered', [
            'tenant'    => $slug,
            'plan'      => $plan,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantSubscribed(
        string $slug,
        string $plan,
        string $provider
    ): void {
        Log::channel('tenants')->info('Tenant subscribed', [
            'tenant'    => $slug,
            'plan'      => $plan,
            'provider'  => $provider,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantCancelled(string $slug, string $reason = ''): void
    {
        Log::channel('tenants')->warning('Tenant cancelled subscription', [
            'tenant'    => $slug,
            'reason'    => $reason,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantGracePeriodStarted(string $slug): void
    {
        Log::channel('tenants')->warning('Grace period started', [
            'tenant'    => $slug,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    // ─── Job logs ─────────────────────────────────────────────────────

    public static function jobDispatched(string $job, array $context = []): void
    {
        Log::channel('jobs')->info("Job dispatched: {$job}", $context);
    }

    public static function jobFailed(
        string $job,
        string $error,
        array $context = []
    ): void {
        Log::channel('jobs')->error("Job failed: {$job}", array_merge(
            ['error' => $error],
            $context
        ));
    }

    // ─── Invoice logs ─────────────────────────────────────────────────

    public static function invoiceSent(
        string $invoiceNumber,
        string $tenantSlug,
        string $clientEmail
    ): void {
        Log::channel('tenants')->info('Invoice sent', [
            'invoice'   => $invoiceNumber,
            'tenant'    => $tenantSlug,
            'to'        => $clientEmail,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function invoicePaid(
        string $invoiceNumber,
        string $tenantSlug,
        int $amount
    ): void {
        Log::channel('payments')->info('Invoice paid', [
            'invoice'   => $invoiceNumber,
            'tenant'    => $tenantSlug,
            'amount'    => $amount,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    // ─── Auth / security audit ──────────────────────────────────────

    public static function tenantUserLoginSuccess(
        string $tenantSlug,
        string $userId,
        string $email
    ): void {
        Log::channel('auth')->info('Tenant user login succeeded', [
            'tenant'    => $tenantSlug,
            'user_id'   => $userId,
            'email'     => $email,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantUserLoginFailed(
        string $tenantSlug,
        string $email
    ): void {
        Log::channel('auth')->warning('Tenant user login failed', [
            'tenant'    => $tenantSlug,
            'email'     => $email,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantUserLoggedOut(string $tenantSlug, string $userId): void
    {
        Log::channel('auth')->info('Tenant user logged out', [
            'tenant'    => $tenantSlug,
            'user_id'   => $userId,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function tenantUserTokenRefreshFailed(string $tenantSlug, string $userId): void
    {
        Log::channel('auth')->warning('Tenant user token refresh failed', [
            'tenant'    => $tenantSlug,
            'user_id'   => $userId,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function workspaceRegistrationFailed(string $message, array $context = []): void
    {
        Log::channel('auth')->error('Workspace registration failed', array_merge(
            ['message' => $message, 'timestamp' => now()->toIso8601String()],
            $context
        ));
    }

    public static function adminLoginSuccess(string $adminId, string $email): void
    {
        Log::channel('auth')->info('Admin login succeeded', [
            'admin_id'  => $adminId,
            'email'     => $email,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function adminLoginFailed(string $email): void
    {
        Log::channel('auth')->warning('Admin login failed', [
            'email'     => $email,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function adminLoggedOut(string $adminId): void
    {
        Log::channel('auth')->info('Admin logged out', [
            'admin_id'  => $adminId,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    // ─── Tenant resolution (support / debugging) ──────────────────────

    public static function tenantHeaderMissing(): void
    {
        Log::channel('tenants')->notice('Tenant could not be identified (no X-Tenant / dev fallback)', [
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    public static function workspaceNotFound(string $slug): void
    {
        Log::channel('tenants')->notice('Workspace not found', [
            'slug'      => $slug,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    // ─── Subscription gate ───────────────────────────────────────────

    public static function subscriptionAccessDenied(string $tenantSlug, string $subscriptionStatus): void
    {
        Log::channel('tenants')->warning('API access denied — subscription not active', [
            'tenant'    => $tenantSlug,
            'status'    => $subscriptionStatus,
            'timestamp' => now()->toIso8601String(),
        ]);
    }
}