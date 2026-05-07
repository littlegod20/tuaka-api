<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f9fafb; margin: 0; padding: 40px 16px; color: #111827; }
    .card { background: #fff; border-radius: 12px; max-width: 520px; margin: 0 auto; padding: 40px; border: 1px solid #e5e7eb; }
    .logo { font-size: 22px; font-weight: 700; margin-bottom: 28px; }
    .logo span { color: #25a572; }
    .alert { padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: 14px; font-weight: 600; }
    .alert-warning { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
    .alert-danger  { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
    h1 { font-size: 20px; font-weight: 600; margin: 0 0 8px; }
    p { color: #6b7280; font-size: 15px; line-height: 1.6; margin: 0 0 20px; }
    .meta { background: #f9fafb; border-radius: 8px; padding: 16px; margin-bottom: 24px; font-size: 14px; }
    .meta-row { display: flex; justify-content: space-between; margin-bottom: 6px; }
    .meta-row:last-child { margin-bottom: 0; }
    .meta-label { color: #6b7280; }
    .meta-value { font-weight: 600; color: #111827; }
    .btn { display: inline-block; background: #25a572; color: #fff; text-decoration: none; padding: 12px 28px; border-radius: 8px; font-weight: 600; font-size: 15px; }
    .footer { text-align: center; margin-top: 32px; font-size: 13px; color: #9ca3af; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Tua<span>Ka</span></div>

    @if($daysUntilDue > 0)
      <div class="alert alert-warning">
        ⏰ Payment due in {{ $daysUntilDue }} day{{ $daysUntilDue === 1 ? '' : 's' }}
      </div>
    @else
      <div class="alert alert-danger">
        🚨 Payment was due today
      </div>
    @endif

    <h1>Invoice reminder</h1>
    <p>
      Hi {{ $client->name }}, this is a friendly reminder that invoice
      <strong>{{ $invoice->number }}</strong> from <strong>{{ $tenant->name }}</strong>
      for <strong>GHS {{ number_format($invoice->total / 100, 2) }}</strong>
      {{ $daysUntilDue > 0 ? 'is due in ' . $daysUntilDue . ' day(s)' : 'is due today' }}.
    </p>

    <div class="meta">
      <div class="meta-row">
        <span class="meta-label">Invoice</span>
        <span class="meta-value">{{ $invoice->number }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Amount due</span>
        <span class="meta-value">GHS {{ number_format($invoice->total / 100, 2) }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Due date</span>
        <span class="meta-value">{{ $invoice->due_date->format('d M Y') }}</span>
      </div>
    </div>

    <a class="btn" href="{{ $invoiceUrl }}">View & pay invoice</a>

    <p style="margin-top: 24px; font-size: 13px; color: #9ca3af;">
      If you've already paid, please ignore this message.
    </p>
  </div>
  <div class="footer">Sent by {{ $tenant->name }} via TuaKa</div>
</body>
</html>