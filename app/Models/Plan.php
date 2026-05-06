<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Plan extends Model
{
    use HasUuid;

    protected $fillable = [
        'name',
        'slug',
        'price_monthly',
        'invoice_limit',
        'features',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'features'      => 'array',
            'is_active'     => 'boolean',
            'price_monthly' => 'integer',
            'invoice_limit' => 'integer',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    // ─── Helpers ──────────────────────────────────────────────────────

    public function isFree(): bool
    {
        return $this->price_monthly === 0;
    }

    public function hasUnlimitedInvoices(): bool
    {
        return $this->invoice_limit === -1;
    }

    /**
     * Expose features as a zero-indexed list so JSON is always [], never {}.
     */
    public static function ensureFeatureList(mixed $features): array
    {
        if ($features === null || ! is_array($features)) {
            return [];
        }

        return array_values($features);
    }

    /**
     * Price formatted as GHS 90.00
     */
    public function formattedPrice(): string
    {
        return 'GHS ' . number_format($this->price_monthly / 100, 2);
    }
}
