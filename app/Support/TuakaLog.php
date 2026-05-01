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
}