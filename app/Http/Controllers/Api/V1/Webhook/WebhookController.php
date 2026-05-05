<?php

namespace App\Http\Controllers\Api\V1\Webhook;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Payment;
use App\Services\PaystackService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class WebhookController extends Controller
{
    public function __construct(private PaystackService $paystack) {}

    public function handlePaystack(Request $request): Response
    {
        $signature = $request->header('x-paystack-signature');
        $payload   = $request->getContent();

        // Always return 200 immediately — Paystack retries on non-200
        if (! $this->paystack->verifyWebhook($payload, $signature ?? '')) {
            return response('', 200);
        }

        $event = $request->input('event');
        $data  = $request->input('data', []);

        if ($event === 'charge.success') {
            $this->handleChargeSuccess($data);
        }

        return response('', 200);
    }

    private function handleChargeSuccess(array $data): void
    {
        $reference = $data['reference'] ?? null;
        if (! $reference) return;

        $payment = Payment::withoutGlobalScopes()
            ->where('provider_ref', $reference)
            ->where('provider', 'paystack')
            ->first();

        if (! $payment || $payment->isCompleted()) return;

        $payment->update([
            'status'  => 'completed',
            'paid_at' => now(),
            'meta'    => array_merge($payment->meta ?? [], ['webhook_data' => $data]),
        ]);

        $invoice = Invoice::withoutGlobalScopes()->find($payment->invoice_id);
        if ($invoice && ! $invoice->isPaid()) {
            $invoice->markAsPaid();
        }
    }
}