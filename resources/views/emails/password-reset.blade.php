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
    .btn { display: inline-block; background: #25a572; color: #fff; text-decoration: none; padding: 12px 28px; border-radius: 8px; font-weight: 600; font-size: 15px; }
    .footer { text-align: center; margin-top: 32px; font-size: 13px; color: #9ca3af; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Tua<span>Ka</span></div>
    <h1>Reset your password</h1>
    <p>Hi {{ $userName }}, we received a request to reset your TuaKa password. Click the button below to choose a new one.</p>
    <a class="btn" href="{{ $resetUrl }}">Reset password</a>
    <p style="margin-top: 24px; font-size: 13px; color: #9ca3af;">
      This link expires in 1 hour. If you didn't request a password reset, you can safely ignore this email.
    </p>
  </div>
  <div class="footer">© {{ date('Y') }} TuaKa. All rights reserved.</div>
</body>
</html>