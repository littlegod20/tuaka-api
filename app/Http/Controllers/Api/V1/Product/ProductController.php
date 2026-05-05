<?php

namespace App\Http\Controllers\Api\V1\Product;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    // ─── List ─────────────────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $query = Product::query();

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('description', 'ilike', "%{$search}%");
            });
        }

        $products = $query
            ->orderBy('name')
            ->paginate($request->query('per_page', 20));

        return response()->json([
            'data' => $products->items(),
            'meta' => [
                'current_page' => $products->currentPage(),
                'last_page'    => $products->lastPage(),
                'per_page'     => $products->perPage(),
                'total'        => $products->total(),
            ],
        ]);
    }

    // ─── Create ───────────────────────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'          => ['required', 'string', 'max:150'],
            'description'   => ['nullable', 'string', 'max:500'],
            'default_price' => ['required', 'integer', 'min:0'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $product = Product::create($request->only([
            'name', 'description', 'default_price',
        ]));

        return response()->json($product, 201);
    }

    // ─── Show ─────────────────────────────────────────────────────────

    public function show(Product $product): JsonResponse
    {
        return response()->json($product);
    }

    // ─── Update ───────────────────────────────────────────────────────

    public function update(Request $request, Product $product): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'          => ['sometimes', 'required', 'string', 'max:150'],
            'description'   => ['nullable', 'string', 'max:500'],
            'default_price' => ['sometimes', 'required', 'integer', 'min:0'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $product->update($request->only([
            'name', 'description', 'default_price',
        ]));

        return response()->json($product);
    }

    // ─── Delete ───────────────────────────────────────────────────────

    public function destroy(Product $product): JsonResponse
    {
        if ($product->invoiceItems()->exists()) {
            return response()->json([
                'message' => 'Cannot delete a product that has been used in invoices.',
            ], 409);
        }

        $product->delete();

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

        $products = Product::query()->whereIn('id', $ids)->get();

        if ($products->count() !== count($ids)) {
            $found = $products->pluck('id')->all();
            $missing = array_values(array_diff($ids, $found));

            return response()->json([
                'message' => 'Some products were not found or do not belong to this workspace.',
                'missing_ids' => $missing,
            ], 422);
        }

        $deletedIds = [];
        $failed     = [];

        DB::transaction(function () use ($products, &$deletedIds, &$failed) {
            foreach ($products as $product) {
                if ($product->invoiceItems()->exists()) {
                    $failed[] = [
                        'id'      => $product->id,
                        'message' => 'Cannot delete a product that has been used in invoices.',
                    ];

                    continue;
                }

                $product->delete();
                $deletedIds[] = $product->id;
            }
        });

        return response()->json([
            'deleted_count' => count($deletedIds),
            'deleted_ids'   => $deletedIds,
            'failed'        => $failed,
        ]);
    }
}