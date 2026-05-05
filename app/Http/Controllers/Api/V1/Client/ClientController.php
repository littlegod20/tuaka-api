<?php

namespace App\Http\Controllers\Api\V1\Client;

use App\Http\Controllers\Controller;
use App\Models\Client;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ClientController extends Controller
{
    // ─── List ─────────────────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $query = Client::query();

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%")
                  ->orWhere('company', 'ilike', "%{$search}%");
            });
        }

        $clients = $query
            ->orderBy('name')
            ->paginate($request->query('per_page', 10));

        return response()->json([
            'data' => $clients->items(),
            'meta' => [
                'current_page' => $clients->currentPage(),
                'last_page'    => $clients->lastPage(),
                'per_page'     => $clients->perPage(),
                'total'        => $clients->total(),
            ],
        ]);
    }

    // ─── Create ───────────────────────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'    => ['required', 'string', 'max:150'],
            'email'   => ['nullable', 'email', 'max:150'],
            'phone'   => ['nullable', 'string', 'max:30'],
            'address' => ['nullable', 'string', 'max:300'],
            'company' => ['nullable', 'string', 'max:150'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $client = Client::create($request->only([
            'name', 'email', 'phone', 'address', 'company',
        ]));

        return response()->json($client, 201);
    }

    // ─── Show ─────────────────────────────────────────────────────────

    public function show(Client $client): JsonResponse
    {
        return response()->json($client);
    }

    // ─── Update ───────────────────────────────────────────────────────

    public function update(Request $request, Client $client): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'    => ['sometimes', 'required', 'string', 'max:150'],
            'email'   => ['nullable', 'email', 'max:150'],
            'phone'   => ['nullable', 'string', 'max:30'],
            'address' => ['nullable', 'string', 'max:300'],
            'company' => ['nullable', 'string', 'max:150'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $client->update($request->only([
            'name', 'email', 'phone', 'address', 'company',
        ]));

        return response()->json($client);
    }

    // ─── Delete ───────────────────────────────────────────────────────

    public function destroy(Client $client): JsonResponse
    {
        // Prevent deleting clients with invoices
        if ($client->invoices()->exists()) {
            return response()->json([
                'message' => 'Cannot delete a client with existing invoices.',
            ], 409);
        }

        $client->delete();

        return response()->json(null, 204);
    }

    // ─── Bulk delete ──────────────────────────────────────────────────

    public function bulkDestroy(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'ids'   => ['required', 'array', 'min:1', 'max:100'],
            'ids.*' => ['uuid', 'distinct'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $ids = array_values(array_unique($request->input('ids', [])));

        $clients = Client::query()->whereIn('id', $ids)->get();

        if ($clients->count() !== count($ids)) {
            $found = $clients->pluck('id')->all();
            $missing = array_values(array_diff($ids, $found));

            return response()->json([
                'message' => 'Some clients were not found or do not belong to this workspace.',
                'missing_ids' => $missing,
            ], 422);
        }

        $deletedIds = [];
        $failed     = [];

        DB::transaction(function () use ($clients, &$deletedIds, &$failed) {
            foreach ($clients as $client) {
                if ($client->invoices()->exists()) {
                    $failed[] = [
                        'id'      => $client->id,
                        'message' => 'Cannot delete a client with existing invoices.',
                    ];

                    continue;
                }

                $client->delete();
                $deletedIds[] = $client->id;
            }
        });

        return response()->json([
            'deleted_count' => count($deletedIds),
            'deleted_ids'   => $deletedIds,
            'failed'        => $failed,
        ]);
    }
}