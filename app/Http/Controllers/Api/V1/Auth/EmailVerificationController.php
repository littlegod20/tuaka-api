<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Mail\VerifyEmailMail;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class EmailVerificationController extends Controller
{
    // ─── Resend verification email ────────────────────────────────────────
    public function resend(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        if ($user->email_verified_at) {
            return response()->json(['message' => 'Email already verified.'], 409);
        }

        $token = Str::random(64);

        $user->update(['email_verification_token' => $token]);

        Log::info('User: ' . json_encode($user));
        Log::info('Token: ' . $token);
        Log::info('Email: ' . $user->email);

        $url = config('app.frontend_url') . '/verify-email?token=' . $token . '&email=' . urlencode($user->email);

        Mail::to($user->email)->queue(new VerifyEmailMail($user, $url));

        return response()->json(['message' => 'Verification email sent.']);
    }

    // ─── Verify email via token ───────────────────────────────────────────
    public function verify(Request $request): JsonResponse
    {
        $token = $request->query('token');
        $email = $request->query('email');

        if (! $token || ! $email) {
            return response()->json(['message' => 'Invalid verification link.'], 422);
        }

        // withoutGlobalScopes() bypasses TenantScope so we can look up
        // by email + token without needing the tenant in context
        $user = User::withoutGlobalScopes()
        ->where('email', $email)
        ->where('email_verification_token', $token)
        ->first();

        Log::info('User: ' . json_encode($user));
        Log::info('Email:' . $email);
        Log::info('Token:' . $token);
        
        if (! $user) {
            return response()->json(['message' => 'Invalid or expired verification link.'], 422);
        }

        $user->update([
            'email_verified_at'        => now(),
            'email_verification_token' => null,
        ]);

        return response()->json(['message' => 'Email verified successfully.']);
    }
}