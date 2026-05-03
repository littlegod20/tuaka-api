<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Support\TuakaLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminAuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $token = auth('admin')->attempt([
            'email'    => $request->email,
            'password' => $request->password,
        ]);

        if (! $token) {
            TuakaLog::adminLoginFailed($request->input('email', ''));

            return response()->json([
                'message' => 'Invalid credentials.',
            ], 401);
        }

        $admin = auth('admin')->user();
        TuakaLog::adminLoginSuccess((string) $admin->id, $admin->email);

        return response()->json([
            'token' => $token,
            'admin' => [
                'id'    => $admin->id,
                'name'  => $admin->name,
                'email' => $admin->email,
            ],
        ]);
    }

    public function logout(): JsonResponse
    {
        $admin = auth('admin')->user();
        if ($admin) {
            TuakaLog::adminLoggedOut((string) $admin->id);
        }

        auth('admin')->logout();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }
}