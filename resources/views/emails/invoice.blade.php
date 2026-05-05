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
    h1 { font-size: 20px; font-weight: 600; margin: 0 0 8px; }
    p { color: #6b7280; font-size: 15px; line-height: 1.6; margin: 0 0 20px; }
    .meta { background: #f9fafb; border-radius: 8px; padding: 16px; margin-bottom: 24px; font-size: 14px; }
    .meta-row { display: flex; justify-content: space-between; margin-bottom: 6px; }
    .meta-row:last-child { margin-bottom: 0; }
    .meta-label { color: #6b7280; }
    .meta-value { font-weight: 600; color: #111827; }
    .btn { display: inline-block; background: #25a572; color: #fff; text-decoration: none; padding: 13px 32px; border-radius: 8px; font-weight: 600; font-size: 15px; }
    .footer { text-align: center; margin-top: 32px; font-size: 13px; color: #9ca3af; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Tua<span>Ka</span></div>
    <h1>
      {{ $invoice->isQuote() ? 'You have a new quote' : 'You have a new invoice' }}
    </h1>
    <p>
      Hi {{ $client->name }}, {{ $tenant->name }} has sent you
      {{ $invoice->isQuote() ? 'a quote' : 'an invoice' }} for
      <strong>GHS {{ number_format($invoice->total / 100, 2) }}</strong>.
    </p>

    <div class="meta">
      <div class="meta-row">
        <span class="meta-label">{{ $invoice->isQuote() ? 'Quote' : 'Invoice' }} number</span>
        <span class="meta-value">{{ $invoice->number }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Amount due</span>
        <span class="meta-value">GHS {{ number_format($invoice->total / 100, 2) }}</span>
      </div>
      @if($invoice->due_date)
      <div class="meta-row">
        <span class="meta-label">Due date</span>
        <span class="meta-value">{{ $invoice->due_date->format('d M Y') }}</span>
      </div>
      @endif
    </div>

    <a class="btn" href="{{ $invoiceUrl }}">
      View {{ $invoice->isQuote() ? 'quote' : 'invoice' }}
    </a>

    <p style="margin-top: 24px; font-size: 13px; color: #9ca3af;">
      If you weren't expecting this, you can safely ignore this email.
    </p>
  </div>
  <div class="footer">Powered by TuaKa &mdash; {{ $tenant->name }}</div>
</body>
</html>