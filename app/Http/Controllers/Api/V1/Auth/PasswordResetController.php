<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Mail\PasswordResetMail;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class PasswordResetController extends Controller
{
    // ─── Send reset link ──────────────────────────────────────────────────
    public function sendLink(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Always return 200 to prevent email enumeration
        $user = User::where('email', $request->email)->first();

        if ($user) {
            // Delete any existing token for this email
            DB::table('password_reset_tokens')
                ->where('email', $request->email)
                ->delete();

            $token = Str::random(64);

            DB::table('password_reset_tokens')->insert([
                'email'      => $request->email,
                'token'      => Hash::make($token),
                'created_at' => now(),
            ]);

            $url = config('app.frontend_url')
                . '/reset-password?token=' . $token
                . '&email=' . urlencode($request->email);

            Mail::to($user->email)->queue(new PasswordResetMail($user, $url));
        }

        return response()->json([
            'message' => 'If that email is registered, a reset link has been sent.',
        ]);
    }

    // ─── Reset password ───────────────────────────────────────────────────
    public function reset(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email'                 => ['required', 'email'],
            'token'                 => ['required', 'string'],
            'password'              => ['required', 'confirmed', Password::min(8)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        // Token expires after 1 hour
        if (
            ! $record ||
            ! Hash::check($request->token, $record->token) ||
            now()->diffInMinutes($record->created_at) > 60
        ) {
            return response()->json([
                'message' => 'This reset link is invalid or has expired.',
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $user->update(['password' => Hash::make($request->password)]);

        DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->delete();

        return response()->json(['message' => 'Password reset successfully.']);
    }
}