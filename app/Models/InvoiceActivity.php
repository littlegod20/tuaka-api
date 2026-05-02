<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvoiceActivity extends Model
{
    use HasUuid;

    // activity log only has created_at, not updated_at
    const UPDATED_AT = null;

    protected $fillable = [
        'invoice_id',
        'type',
        'meta',
    ];

    protected function casts(): array
    {
        return [
            'meta'       => 'array',
            'created_at' => 'datetime',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }
}
