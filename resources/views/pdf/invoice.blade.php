<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: DejaVu Sans, sans-serif;
      font-size: 13px;
      color: #111827;
      background: #fff;
    }

    .page {
      padding: 48px;
    }

    /* ── Header ── */
    .header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 40px;
    }

    .logo {
      font-size: 22px;
      font-weight: 700;
      color: #111827;
    }

    .logo span {
      color: #25A572;
 
    }

    .invoice-meta {
      text-align: right;
    }

    .invoice-number {
      font-size: 20px;
      font-weight: 700;
      color: #111827;
    }

    .status-badge {
      display: inline-block;
      margin-top: 6px;
      padding: 3px 10px;
      border-radius: 99px;
      font-size: 11px;
      font-weight: 600;
      text-transform: capitalize;
    }

    .status-draft   { background: #f3f4f6; color: #4b5563; }
    .status-sent    { background: #eff6ff; color: #2563eb; }
    .status-viewed  { background: #f5f3ff; color: #7c3aed; }
    .status-paid    { background: #f0fdf4; color: #16a34a; }
    .status-overdue { background: #fef2f2; color: #dc2626; }

    /* ── Parties ── */
    .parties {
      display: flex;
      justify-content: space-between;
      margin-bottom: 36px;
      gap: 40px;
    }

    .party {
      flex: 1;
    }

    .party-label {
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #9ca3af;
      margin-bottom: 6px;
    }

    .party-name {
      font-size: 15px;
      font-weight: 600;
      color: #111827;
      margin-bottom: 3px;
    }

    .party-detail {
      font-size: 12px;
      color: #6b7280;
      line-height: 1.6;
    }

    /* ── Dates row ── */
    .dates {
      display: flex;
      gap: 40px;
      margin-bottom: 36px;
      padding: 16px 20px;
      background: #f9fafb;
      border-radius: 8px;
    }

    .date-item {}

    .date-label {
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #9ca3af;
      margin-bottom: 3px;
    }

    .date-value {
      font-size: 13px;
      font-weight: 600;
      color: #111827;
    }

    /* ── Line items table ── */
    .items-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 24px;
    }

    .items-table thead tr {
      border-bottom: 2px solid #e5e7eb;
    }

    .items-table thead th {
      padding: 8px 12px;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      color: #6b7280;
      text-align: left;
    }

    .items-table thead th.right { text-align: right; }

    .items-table tbody tr {
      border-bottom: 1px solid #f3f4f6;
    }

    .items-table tbody td {
      padding: 12px 12px;
      font-size: 13px;
      color: #374151;
      vertical-align: top;
    }

    .items-table tbody td.right {
      text-align: right;
      font-weight: 500;
      color: #111827;
    }

    /* ── Totals ── */
    .totals {
      width: 260px;
      margin-left: auto;
      margin-bottom: 32px;
    }

    .totals-row {
      display: flex;
      justify-content: space-between;
      padding: 5px 0;
      font-size: 13px;
      color: #6b7280;
    }

    .totals-row.total {
      border-top: 2px solid #e5e7eb;
      margin-top: 6px;
      padding-top: 10px;
      font-size: 15px;
      font-weight: 700;
      color: #111827;
    }

    /* ── Notes ── */
    .notes {
      border-top: 1px solid #e5e7eb;
      padding-top: 20px;
      margin-top: 8px;
    }

    .notes-label {
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #9ca3af;
      margin-bottom: 6px;
    }

    .notes-text {
      font-size: 12px;
      color: #6b7280;
      line-height: 1.7;
    }

    /* ── Footer ── */
    .footer {
      margin-top: 48px;
      padding-top: 16px;
      border-top: 1px solid #f3f4f6;
      text-align: center;
      font-size: 11px;
      color: #d1d5db;
    }
  </style>
</head>
<body>
<div class="page">

  {{-- Header --}}
  <div class="header">
    <div class="logo">Tua<span>Ka</span></div>
    <div class="invoice-meta">
      <div class="invoice-number">{{ $invoice->number }}</div>
      <div class="status-badge status-{{ $invoice->status }}">
        {{ $invoice->status }}
      </div>
    </div>
  </div>

  {{-- Parties --}}
  <div class="parties">
    <div class="party">
      <div class="party-label">From</div>
      <div class="party-name">{{ $tenant->name }}</div>
      <div class="party-detail">
        @if($tenant->address) {{ $tenant->address }}<br> @endif
        @if($tenant->phone) {{ $tenant->phone }}<br> @endif
        @if($tenant->website) {{ $tenant->website }} @endif
      </div>
    </div>
    <div class="party">
      <div class="party-label">Bill to</div>
      <div class="party-name">{{ $client->name }}</div>
      <div class="party-detail">
        @if($client->company) {{ $client->company }}<br> @endif
        @if($client->email) {{ $client->email }}<br> @endif
        @if($client->phone) {{ $client->phone }}<br> @endif
        @if($client->address) {{ $client->address }} @endif
      </div>
    </div>
  </div>

  {{-- Dates --}}
  <div class="dates">
    <div class="date-item">
      <div class="date-label">{{ $invoice->isQuote() ? 'Quote' : 'Invoice' }} date</div>
      <div class="date-value">{{ $invoice->created_at->format('d M Y') }}</div>
    </div>
    @if($invoice->due_date)
    <div class="date-item">
      <div class="date-label">Due date</div>
      <div class="date-value">{{ $invoice->due_date->format('d M Y') }}</div>
    </div>
    @endif
    @if($invoice->paid_at)
    <div class="date-item">
      <div class="date-label">Paid on</div>
      <div class="date-value">{{ $invoice->paid_at->format('d M Y') }}</div>
    </div>
    @endif
  </div>

  {{-- Line items --}}
  <table class="items-table">
    <thead>
      <tr>
        <th>Description</th>
        <th class="right" style="width:60px">Qty</th>
        <th class="right" style="width:110px">Unit price</th>
        <th class="right" style="width:110px">Total</th>
      </tr>
    </thead>
    <tbody>
      @foreach($invoice->items as $item)
      <tr>
        <td>{{ $item->description }}</td>
        <td class="right">{{ $item->quantity }}</td>
        <td class="right">GHS {{ number_format($item->unit_price / 100, 2) }}</td>
        <td class="right">GHS {{ number_format($item->total / 100, 2) }}</td>
      </tr>
      @endforeach
    </tbody>
  </table>

  {{-- Totals --}}
  <div class="totals">
    <div class="totals-row">
      <span>Subtotal</span>
      <span>GHS {{ number_format($invoice->subtotal / 100, 2) }}</span>
    </div>
    @if($invoice->tax_rate > 0)
    <div class="totals-row">
      <span>Tax ({{ $invoice->tax_rate }}%)</span>
      <span>GHS {{ number_format($invoice->tax_amount / 100, 2) }}</span>
    </div>
    @endif
    <div class="totals-row total">
      <span>Total</span>
      <span>GHS {{ number_format($invoice->total / 100, 2) }}</span>
    </div>
  </div>

  {{-- Notes --}}
  @if($invoice->notes)
  <div class="notes">
    <div class="notes-label">Notes</div>
    <div class="notes-text">{{ $invoice->notes }}</div>
  </div>
  @endif

  {{-- Footer --}}
  <div class="footer">
    Generated by TuaKa &mdash; {{ $tenant->name }} &mdash; {{ now()->format('d M Y') }}
  </div>

</div>
</body>
</html> 