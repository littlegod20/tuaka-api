<?php

namespace App\Http\Controllers\Api\V1\Payment;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Payment;
use App\Services\PaystackService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentController extends Controller
{
    public function __construct(private PaystackService $paystack) {}

    // ─── Initiate payment ─────────────────────────────────────────────

    public function initiate(Request $request, string $token): JsonResponse
    {
        $invoice = Invoice::withoutGlobalScopes()
            ->with(['client', 'tenant'])
            ->where('view_token', $token)
            ->firstOrFail();

        if ($invoice->isPaid()) {
            return response()->json([
                'message' => 'Invoice is already paid.',
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'phone'   => ['required', 'string', 'min:10', 'max:15'],
            'network' => ['required', 'in:mtn,vodafone,tigo'],
            'email'   => ['required', 'email'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Check for existing pending payment to avoid duplicates
        $existing = Payment::withoutGlobalScopes()
            ->where('invoice_id', $invoice->id)
            ->where('status', 'pending')
            ->latest()
            ->first();

        if ($existing) {
            return response()->json([
                'message'   => 'A payment is already in progress.',
                'reference' => $existing->provider_ref,
            ], 422);
        }

        $reference = PaystackService::generateReference($invoice->id);

        // Create pending payment record first (idempotency)
        $payment = Payment::withoutGlobalScopes()->create([
            'invoice_id'   => $invoice->id,
            'tenant_id'    => $invoice->tenant_id,
            'provider'     => 'paystack',
            'provider_ref' => $reference,
            'amount'       => $invoice->total,
            'status'       => 'pending',
            'meta'         => [
                'phone'   => $request->phone,
                'network' => $request->network,
                'email'   => $request->email,
            ],
        ]);

        // Call Paystack
        $result = $this->paystack->chargeMobileMoney(
            phone:             $request->phone,
            network:           $request->network,
            amountInPesewas:   $invoice->total,
            email:             $request->email,
            reference:         $reference,
            metadata:          [
                'invoice_number' => $invoice->number,
                'invoice_id'     => $invoice->id,
                'tenant_id'      => $invoice->tenant_id,
            ],
        );

        if (! ($result['status'] ?? false)) {
            $payment->update(['status' => 'failed']);
            return response()->json([
                'message' => $result['message'] ?? 'Payment initiation failed.',
            ], 422);
        }

        $data   = $result['data'] ?? [];
        $status = $data['status'] ?? '';

        // MTN prompts the user on their phone — we return pending
        // Vodafone returns a display_text asking user to check phone
        return response()->json([
            'message'      => $result['message'] ?? 'Payment initiated.',
            'reference'    => $reference,
            'status'       => $status,
            'display_text' => $data['display_text'] ?? null,
        ]);
    }

    // ─── Poll payment status ──────────────────────────────────────────

    public function status(string $token, string $reference): JsonResponse
    {
        $invoice = Invoice::withoutGlobalScopes()
            ->where('view_token', $token)
            ->firstOrFail();

        $payment = Payment::withoutGlobalScopes()
            ->where('invoice_id', $invoice->id)
            ->where('provider_ref', $reference)
            ->firstOrFail();

        // If already resolved locally, return immediately
        if ($payment->status !== 'pending') {
            return response()->json([
                'status'  => $payment->status,
                'paid'    => $payment->isCompleted(),
            ]);
        }

        // Check with Paystack
        $result = $this->paystack->getCharge($reference);
        $data   = $result['data'] ?? [];
        $status = $data['status'] ?? 'pending';

        if ($status === 'success') {
            $payment->update([
                'status'  => 'completed',
                'paid_at' => now(),
                'meta'    => array_merge($payment->meta ?? [], ['paystack_data' => $data]),
            ]);

            // Mark invoice as paid
            if (! $invoice->isPaid()) {
                $invoice->markAsPaid();
            }

            return response()->json([
                'status' => 'completed',
                'paid'   => true,
            ]);
        }

        if (in_array($status, ['failed', 'abandoned', 'reversed'])) {
            $payment->update(['status' => 'failed']);

            return response()->json([
                'status' => 'failed',
                'paid'   => false,
            ]);
        }

        return response()->json([
            'status' => 'pending',
            'paid'   => false,
        ]);
    }
}