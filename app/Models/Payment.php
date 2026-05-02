<?php

namespace App\Models;

use App\Traits\HasTenant;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasUuid;
    use HasTenant;

    protected $fillable = [
        'invoice_id',
        'tenant_id',
        'provider',
        'provider_ref',
        'amount',
        'status',
        'meta',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'amount'  => 'integer',
            'meta'    => 'array',
            'paid_at' => 'datetime',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    // ─── Helpers ──────────────────────────────────────────────────────

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }
}
