<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f9fafb; margin: 0; padding: 40px 16px; color: #111827; }
    .card { background: #fff; border-radius: 12px; max-width: 480px; margin: 0 auto; padding: 40px; border: 1px solid #e5e7eb; }
    .logo { font-size: 24px; font-weight: 700; margin-bottom: 32px; }
    .logo span { color: #25a572; }
    h1 { font-size: 20px; font-weight: 600; margin: 0 0 8px; }
    p { color: #6b7280; font-size: 15px; line-height: 1.6; margin: 0 0 24px; }
    .meta { background: #f9fafb; border-radius: 8px; padding: 16px; margin-bottom: 24px; font-size: 14px; }
    .meta-row { display: flex; justify-content: space-between; margin-bottom: 6px; }
    .meta-row:last-child { margin-bottom: 0; }
    .meta-label { color: #6b7280; }
    .meta-value { font-weight: 600; color: #111827; text-transform: capitalize; }
    .btn { display: inline-block; background: #25a572; color: #fff; text-decoration: none; padding: 12px 28px; border-radius: 8px; font-weight: 600; font-size: 15px; }
    .footer { text-align: center; margin-top: 32px; font-size: 13px; color: #9ca3af; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Tua<span>Ka</span></div>
    <h1>You're invited!</h1>
    <p>
      {{ $invitedBy->name }} has invited you to join
      <strong>{{ $tenant->name }}</strong> on TuaKa as a
      <strong>{{ $invite->role }}</strong>.
    </p>

    <div class="meta">
      <div class="meta-row">
        <span class="meta-label">Workspace</span>
        <span class="meta-value">{{ $tenant->name }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Your role</span>
        <span class="meta-value">{{ $invite->role }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Invited by</span>
        <span class="meta-value">{{ $invitedBy->name }}</span>
      </div>
      <div class="meta-row">
        <span class="meta-label">Expires</span>
        <span class="meta-value">{{ $invite->expires_at->format('d M Y, g:i A') }}</span>
      </div>
    </div>

    <a class="btn" href="{{ $acceptUrl }}">Accept invitation</a>

    <p style="margin-top: 24px; font-size: 13px; color: #9ca3af;">
      This invitation expires in 48 hours. If you weren't expecting this, ignore it.
    </p>
  </div>
  <div class="footer">© {{ date('Y') }} TuaKa. All rights reserved.</div>
</body>
</html>