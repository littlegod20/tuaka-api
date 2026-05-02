<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Subscription extends Model
{
    use HasUuid;

    protected $fillable = [
        'tenant_id',
        'plan_id',
        'status',
        'paystack_ref',
        'trial_ends_at',
        'current_period_start',
        'current_period_end',
        'cancelled_at',
    ];

    protected function casts(): array
    {
        return [
            'trial_ends_at'        => 'datetime',
            'current_period_start' => 'datetime',
            'current_period_end'   => 'datetime',
            'cancelled_at'         => 'datetime',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

    // ─── Status helpers ───────────────────────────────────────────────

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isTrialing(): bool
    {
        return $this->status === 'trialing'
            && $this->trial_ends_at?->isFuture();
    }

    public function isInGracePeriod(): bool
    {
        return $this->status === 'grace_period';
    }

    public function isCancelled(): bool
    {
        return $this->status === 'cancelled';
    }

    public function isValid(): bool
    {
        return $this->isActive()
            || $this->isTrialing()
            || $this->isInGracePeriod();
    }
}
