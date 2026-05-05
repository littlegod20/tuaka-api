<?php

namespace App\Http\Controllers\Api\V1\Invoice;

use App\Http\Controllers\Controller;
use App\Mail\InvoiceMail;
use App\Models\Invoice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Barryvdh\DomPDF\Facade\Pdf;
use Throwable;

class InvoiceController extends Controller
{
    // ─── List ─────────────────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $query = Invoice::with(['client'])
            ->orderByDesc('created_at');

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        if ($type = $request->query('type')) {
            $query->where('type', $type);
        }

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('number', 'ilike', "%{$search}%")
                  ->orWhereHas('client', fn($q) =>
                      $q->where('name', 'ilike', "%{$search}%")
                  );
            });
        }

        $invoices = $query->paginate($request->query('per_page', 20));

        return response()->json([
            'data' => $invoices->items(),
            'meta' => [
                'current_page' => $invoices->currentPage(),
                'last_page'    => $invoices->lastPage(),
                'per_page'     => $invoices->perPage(),
                'total'        => $invoices->total(),
            ],
        ]);
    }

    // ─── Create ───────────────────────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'client_id'          => ['required', 'uuid', 'exists:clients,id'],
            'type'               => ['sometimes', 'in:invoice,quote'],
            'tax_rate'           => ['sometimes', 'integer', 'min:0', 'max:100'],
            'notes'              => ['nullable', 'string', 'max:1000'],
            'due_date'           => ['nullable', 'date', 'after_or_equal:today'],
            'items'              => ['required', 'array', 'min:1'],
            'items.*.description'=> ['required', 'string', 'max:300'],
            'items.*.quantity'   => ['required', 'integer', 'min:1'],
            'items.*.unit_price' => ['required', 'integer', 'min:0'],
            'items.*.product_id' => ['nullable', 'uuid', 'exists:products,id'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            $tenant = app('current_tenant');
            $type   = $request->input('type', 'invoice');
            $number = $type === 'quote'
                ? $tenant->nextQuoteNumber()
                : $tenant->nextInvoiceNumber();

            $invoice = Invoice::create([
                'client_id' => $request->client_id,
                'type'      => $type,
                'status'    => 'draft',
                'number'    => $number,
                'tax_rate'  => $request->input('tax_rate', 0),
                'notes'     => $request->notes,
                'due_date'  => $request->due_date,
            ]);

            foreach ($request->items as $index => $item) {
                $invoice->items()->create([
                    'product_id'  => $item['product_id'] ?? null,
                    'description' => $item['description'],
                    'quantity'    => $item['quantity'],
                    'unit_price'  => $item['unit_price'],
                    'sort_order'  => $index,
                ]);
            }

            $invoice->recalculateTotals();

            $invoice->activities()->create([
                'type' => 'created',
                'meta' => ['by' => auth('api')->id()],
            ]);

            DB::commit();

            return response()->json(
                $invoice->fresh(['client', 'items']),
                201
            );

        } catch (Throwable $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create invoice.',
            ], 500);
        }
    }

    // ─── Show ─────────────────────────────────────────────────────────

    public function show(Invoice $invoice): JsonResponse
    {
        return response()->json(
            $invoice->load(['client', 'items', 'activities'])
        );
    }

    // ─── Update ───────────────────────────────────────────────────────

    public function update(Request $request, Invoice $invoice): JsonResponse
    {
        if (! $invoice->isDraft()) {
            return response()->json([
                'message' => 'Only draft invoices can be edited.',
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'client_id'          => ['sometimes', 'uuid', 'exists:clients,id'],
            'tax_rate'           => ['sometimes', 'integer', 'min:0', 'max:100'],
            'notes'              => ['nullable', 'string', 'max:1000'],
            'due_date'           => ['nullable', 'date'],
            'items'              => ['sometimes', 'array', 'min:1'],
            'items.*.id'         => ['nullable', 'uuid'],
            'items.*.description'=> ['required', 'string', 'max:300'],
            'items.*.quantity'   => ['required', 'integer', 'min:1'],
            'items.*.unit_price' => ['required', 'integer', 'min:0'],
            'items.*.product_id' => ['nullable', 'uuid', 'exists:products,id'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            $invoice->update($request->only([
                'client_id', 'tax_rate', 'notes', 'due_date',
            ]));

            if ($request->has('items')) {
                // Replace all items — simplest strategy for an invoice editor
                $invoice->items()->delete();

                foreach ($request->items as $index => $item) {
                    $invoice->items()->create([
                        'product_id'  => $item['product_id'] ?? null,
                        'description' => $item['description'],
                        'quantity'    => $item['quantity'],
                        'unit_price'  => $item['unit_price'],
                        'sort_order'  => $index,
                    ]);
                }

                $invoice->recalculateTotals();
            }

            DB::commit();

            return response()->json(
                $invoice->fresh(['client', 'items'])
            );

        } catch (Throwable $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to update invoice.',
            ], 500);
        }
    }

    // ─── Delete ───────────────────────────────────────────────────────

    public function destroy(Invoice $invoice): JsonResponse
    {
        if (! $invoice->isDraft()) {
            return response()->json([
                'message' => 'Only draft invoices can be deleted.',
            ], 422);
        }

        $invoice->delete();

        return response()->json(null, 204);
    }

    // ─── Send ─────────────────────────────────────────────────────────

    public function send(Invoice $invoice): JsonResponse
    {
        if ($invoice->isPaid()) {
            return response()->json([
                'message' => 'Invoice is already paid.',
            ], 422);
        }

        if (! $invoice->client->email) {
            return response()->json([
                'message' => 'Client has no email address.',
            ], 422);
        }

        $invoice->generateViewToken();

        $invoice->update([
            'status'  => 'sent',
            'sent_at' => now(),
        ]);

        $url = config('app.frontend_url')
            . '/inv/' . $invoice->view_token;

        Mail::to($invoice->client->email)
            ->queue(new InvoiceMail($invoice->fresh('tenant'), $url));

        $invoice->activities()->create([
            'type' => 'sent',
            'meta' => [
                'to'      => $invoice->client->email,
                'sent_at' => now()->toIso8601String(),
            ],
        ]);

        return response()->json([
            'message' => 'Invoice sent.',
            'invoice' => $invoice->fresh(['client', 'items']),
        ]);
    }

    // ─── Mark paid ────────────────────────────────────────────────────

    public function markPaid(Invoice $invoice): JsonResponse
    {
        if ($invoice->isPaid()) {
            return response()->json([
                'message' => 'Invoice is already marked as paid.',
            ], 422);
        }

        $invoice->markAsPaid();

        return response()->json([
            'message' => 'Invoice marked as paid.',
            'invoice' => $invoice->fresh(['client', 'items']),
        ]);
    }

    // ─── Convert quote → invoice ──────────────────────────────────────

    public function convert(Invoice $invoice): JsonResponse
    {
        if (! $invoice->isQuote()) {
            return response()->json([
                'message' => 'Only quotes can be converted.',
            ], 422);
        }

        $invoice->convertToInvoice();

        return response()->json([
            'message' => 'Quote converted to invoice.',
            'invoice' => $invoice->fresh(['client', 'items']),
        ]);
    }

    // ─── Public view (token-based, no auth) ───────────────────────────

    public function publicView(string $token): JsonResponse
    {
        $invoice = Invoice::withoutGlobalScopes()
            ->with(['client', 'items', 'tenant'])
            ->where('view_token', $token)
            ->firstOrFail();

        $invoice->recordView();

        return response()->json($invoice);
    }

    // ─── Download PDF (authenticated) ────────────────────────────────────

    public function download(Invoice $invoice): \Illuminate\Http\Response
    {
        $invoice->load(['client', 'items', 'tenant']);

        $pdf = Pdf::loadView('pdf.invoice', [
            'invoice' => $invoice,
            'tenant'  => $invoice->tenant,
            'client'  => $invoice->client,
        ]);

        $filename = strtolower($invoice->number) . '.pdf';

        return $pdf->download($filename);
    }

    // ─── Download PDF (public token) ─────────────────────────────────────

    public function downloadPublic(string $token): \Illuminate\Http\Response
    {
        $invoice = Invoice::withoutGlobalScopes()
            ->with(['client', 'items', 'tenant'])
            ->where('view_token', $token)
            ->firstOrFail();

        $pdf = Pdf::loadView('pdf.invoice', [
            'invoice' => $invoice,
            'tenant'  => $invoice->tenant,
            'client'  => $invoice->client,
        ]);

        $filename = strtolower($invoice->number) . '.pdf';

        return $pdf->download($filename);
    }
}