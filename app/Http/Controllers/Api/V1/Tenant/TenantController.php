<?php

namespace App\Http\Controllers\Api\V1\Tenant;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TenantController extends Controller
{
    public function show(): JsonResponse
    {
        return response()->json(app('current_tenant'));
    }

    public function update(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'           => ['sometimes', 'required', 'string', 'max:100'],
            'invoice_prefix' => ['sometimes', 'required', 'string', 'max:10', 'regex:/^[A-Z0-9\-]+$/'],
            'currency'       => ['sometimes', 'required', 'string', 'size:3'],
            'timezone'       => ['sometimes', 'required', 'string', 'max:50'],
            'address'        => ['nullable', 'string', 'max:300'],
            'phone'          => ['nullable', 'string', 'max:30'],
            'website'        => ['nullable', 'url', 'max:150'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $tenant = app('current_tenant');
        $tenant->update($request->only([
            'name', 'invoice_prefix', 'currency',
            'timezone', 'address', 'phone', 'website',
        ]));

        return response()->json($tenant->fresh());
    }
}