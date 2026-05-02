<?php

namespace App\Models;

use App\Traits\HasTenant;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Invoice extends Model
{
    use HasUuid;
    use HasTenant;

    protected $fillable = [
        'tenant_id',
        'client_id',
        'number',
        'type',
        'status',
        'view_token',
        'subtotal',
        'tax_rate',
        'tax_amount',
        'total',
        'notes',
        'due_date',
        'sent_at',
        'viewed_at',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'due_date'   => 'date',
            'sent_at'    => 'datetime',
            'viewed_at'  => 'datetime',
            'paid_at'    => 'datetime',
            'subtotal'   => 'integer',
            'tax_rate'   => 'integer',
            'tax_amount' => 'integer',
            'total'      => 'integer',
        ];
    }

    // ─── Relationships ────────────────────────────────────────────────

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(InvoiceItem::class)
                    ->orderBy('sort_order');
    }

    public function activities(): HasMany
    {
        return $this->hasMany(InvoiceActivity::class)
                    ->latest('created_at');
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    // ─── Status helpers ───────────────────────────────────────────────

    public function isDraft(): bool    { return $this->status === 'draft'; }
    public function isSent(): bool     { return $this->status === 'sent'; }
    public function isViewed(): bool   { return $this->status === 'viewed'; }
    public function isPaid(): bool     { return $this->status === 'paid'; }
    public function isOverdue(): bool  { return $this->status === 'overdue'; }
    public function isInvoice(): bool  { return $this->type === 'invoice'; }
    public function isQuote(): bool    { return $this->type === 'quote'; }

    // ─── Actions ──────────────────────────────────────────────────────

    /**
     * Generate and store a unique view token.
     * Called just before the invoice is sent.
     */
    public function generateViewToken(): void
    {
        $this->update([
            'view_token' => Str::random(64),
        ]);
    }

    /**
     * Record that the client opened the invoice.
     * Only sets viewed_at on the first view.
     */
    public function recordView(): void
    {
        if (! $this->viewed_at) {
            $this->update([
                'status'    => 'viewed',
                'viewed_at' => now(),
            ]);
        }

        $this->activities()->create([
            'type' => 'viewed',
            'meta' => ['ip' => request()->ip()],
        ]);
    }

    /**
     * Mark the invoice as paid.
     */
    public function markAsPaid(): void
    {
        $this->update([
            'status'  => 'paid',
            'paid_at' => now(),
        ]);

        $this->activities()->create([
            'type' => 'paid',
            'meta' => ['paid_at' => now()->toIso8601String()],
        ]);
    }

    /**
     * Convert a quote to an invoice.
     * Resets status to draft and clears sent/viewed timestamps.
     */
    public function convertToInvoice(): void
    {
        $this->update([
            'type'       => 'invoice',
            'status'     => 'draft',
            'number'     => $this->tenant->nextInvoiceNumber(),
            'view_token' => null,
            'sent_at'    => null,
            'viewed_at'  => null,
        ]);

        $this->activities()->create([
            'type' => 'converted',
            'meta' => ['converted_at' => now()->toIso8601String()],
        ]);
    }

    /**
     * Recalculate subtotal, tax, and total from line items.
     * Call this after adding or updating items.
     */
    public function recalculateTotals(): void
    {
        $subtotal   = $this->items()->sum('total');
        $taxAmount  = (int) round($subtotal * ($this->tax_rate / 100));

        $this->update([
            'subtotal'   => $subtotal,
            'tax_amount' => $taxAmount,
            'total'      => $subtotal + $taxAmount,
        ]);
    }
}
