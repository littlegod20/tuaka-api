<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaystackService
{
    private string $baseUrl = 'https://api.paystack.co';
    private string $secretKey;

    public function __construct()
    {
        $this->secretKey = config('services.paystack.secret_key');
    }

    // ─── Initiate mobile money charge ─────────────────────────────────

    public function chargeMobileMoney(
        string $phone,
        string $network,
        int    $amountInPesewas,
        string $email,
        string $reference,
        array  $metadata = [],
    ): array {
        // Paystack expects amount in kobo/pesewas (smallest unit)
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/charge", [
                'amount'       => $amountInPesewas,
                'email'        => $email,
                'currency'     => 'GHS',
                'reference'    => $reference,
                'mobile_money' => [
                    'phone'    => $phone,
                    'provider' => strtolower($network), // mtn, vodafone, tigo
                ],
                'metadata'     => $metadata,
            ]);

        return $response->json();
    }

    // ─── Check charge status ──────────────────────────────────────────

    public function getCharge(string $reference): array
    {
        $response = Http::withToken($this->secretKey)
            ->get("{$this->baseUrl}/charge/{$reference}");

        return $response->json();
    }

    // ─── Submit OTP or PIN (Vodafone requires this) ───────────────────

    public function submitOtp(string $reference, string $otp): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/charge/submit_otp", [
                'reference' => $reference,
                'otp'       => $otp,
            ]);

        return $response->json();
    }

    // ─── Verify webhook signature ──────────────────────────────────────

    public function verifyWebhook(string $payload, string $signature): bool
    {
        $expected = hash_hmac(
            'sha512',
            $payload,
            config('services.paystack.webhook_secret'),
        );

        return hash_equals($expected, $signature);
    }

    // ─── Generate unique reference ─────────────────────────────────────

    public static function generateReference(string $invoiceId): string
    {
        return 'TK-' . strtoupper(substr($invoiceId, 0, 8)) . '-' . strtoupper(Str::random(8));
    }
}