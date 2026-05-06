<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Tenant extends Model
{
    use HasUuid;

    protected $fillable = [
        'name',
        'slug',
        'currency',
        'logo_url',
        'invoice_prefix',
        'address',
        'phone',
        'website',
        'timezone',
        'is_active'
    ];

    // ─── Relationships ────────────────────────────────────────────────

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(Subscription::class)
        ->orderByDesc('created_at')
        ->limit(1);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }

    public function clients(): HasMany
    {
        return $this->hasMany(Client::class);
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    // ─── Helpers ──────────────────────────────────────────────────────

    /**
     * Check if the tenant has an active or trialing subscription.
     */
    public function hasActiveSubscription(): bool
    {
        return $this->subscription()
                    ->whereIn('status', ['active', 'trialing'])
                    ->exists();
    }

    /**
     * Generate the next sequential invoice number for this tenant.
     * Uses a DB-level lock to prevent duplicates under concurrent requests.
     * e.g. INV-0001, INV-0002, ...
     */
    public function nextInvoiceNumber(): string
    {
        $this->refresh(); // to ensure we have the latest prefix
        $prefix = $this->invoice_prefix ?? 'INV';

        $latest = \App\Models\Invoice::withoutGlobalScopes()
            ->where('tenant_id', $this->id)
            ->where('type', 'invoice')
            ->lockForUpdate()
            ->orderByRaw("CAST(SUBSTRING(number FROM '[0-9]+$') AS INTEGER) DESC")
            ->value('number');

        $next = 1;

        if ($latest) {
            preg_match('/(\d+)$/', $latest, $matches);
            $next = isset($matches[1]) ? ((int) $matches[1]) + 1 : 1;
        }

        return $prefix . '-' . str_pad($next, 4, '0', STR_PAD_LEFT);
    }

    public function nextQuoteNumber(): string
    {
        $latest = \App\Models\Invoice::withoutGlobalScopes()
            ->where('tenant_id', $this->id)
            ->where('type', 'quote')
            ->lockForUpdate()
            ->orderByRaw("CAST(SUBSTRING(number FROM '[0-9]+$') AS INTEGER) DESC")
            ->value('number');

        $next = 1;

        if ($latest) {
            preg_match('/(\d+)$/', $latest, $matches);
            $next = isset($matches[1]) ? ((int) $matches[1]) + 1 : 1;
        }

        return 'QUO-' . str_pad($next, 4, '0', STR_PAD_LEFT);
    }

    /**
     * Format a monetary amount using this tenant's currency.
     * Amounts are stored in smallest unit (pesewas).
     */
    public function formatMoney(int $amountInPesewas): string
    {
        $amount = $amountInPesewas / 100;
        return $this->currency . ' ' . number_format($amount, 2);
    }
}
