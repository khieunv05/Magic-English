<?php

namespace Modules\Admin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

use Modules\Admin\Http\Requests\LoginRequest;

use App\Models\User;

class AuthController extends \App\Http\Controllers\Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $email    = strtolower(trim($request->input('email')));
        $password = (string) $request->input('password');

        $user = User::with(['wallet', 'roles.permissions'])
            ->where('email', $email)
            ->first();

        if (!$user || !Hash::check($password, $user->password)) {
            return $this->apiResponse(false, 'Incorrect login information.');
        }

        if ($user->status !== 'active') {
            return $this->apiResponse(false, match ($user->status) {
                'pending'  => 'Your registration is pending approval. Please wait for confirmation.',
                'inactive' => 'Your account is inactive. Please contact support.',
                'banned'   => 'Your account has been banned. Access denied.',
                default    => 'Account status invalid.',
            });
        }

        if ($user->is_staff !== 'staff') {
            return $this->apiResponse(false, 'You do not have admin access.');
        }

        $deviceName = $request->header('X-Device-Name')
            ?? mb_strimwidth((string) $request->userAgent(), 0, 255, '');
        if (!$deviceName) {
            $deviceName = 'admin';
        }

        $user->tokens()->where('name', $deviceName)->delete();

        $abilities = $user->roles
            ->flatMap(fn($role) => $role->permissions)
            ->pluck('key')
            ->filter()
            ->unique()
            ->values()
            ->all();

        $plainTextToken = $user->createToken($deviceName, $abilities)->plainTextToken;

        $user->setHidden(['password', 'remember_token', 'roles']);

        return $this->apiResponse(true, 'Login successful', [
            ...$user->toArray(),
            'token'       => $plainTextToken,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->apiResponse(true, 'Logout successful');
    }
}
