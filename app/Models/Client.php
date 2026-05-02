<?php

namespace App\Models;

use App\Traits\HasTenant;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Client extends Model
{
    use HasUuid;
    use HasTenant;

    protected $fillable = [
        'tenant_id',
        'name',
        'email',
        'phone',
        'address',
        'company',
    ];

    // ─── Relationships ────────────────────────────────────────────────

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }

    // ─── Helpers ──────────────────────────────────────────────────────

    public function totalBilled(): int
    {
        return $this->invoices()->sum('total');
    }

    public function totalOutstanding(): int
    {
        return $this->invoices()
                    ->whereNotIn('status', ['paid', 'draft'])
                    ->sum('total');
    }
}
