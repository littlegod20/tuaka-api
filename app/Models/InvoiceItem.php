<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvoiceItem extends Model
{
    use HasUuid;

    protected $fillable = [
        'invoice_id',
        'product_id',
        'description',
        'quantity',
        'unit_price',
        'total',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'quantity'   => 'integer',
            'unit_price' => 'integer',
            'total'      => 'integer',
            'sort_order' => 'integer',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    // ─── Hooks ───────────────────────────────────────────────────────

    protected static function booted(): void
    {
        // Recalculate item total whenever quantity or price changes
        static::saving(function (InvoiceItem $item) {
            $item->total = $item->quantity * $item->unit_price;
        });
    }
}
