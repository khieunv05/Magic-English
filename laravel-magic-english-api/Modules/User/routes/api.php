<?php

use Illuminate\Support\Facades\Route;
use Modules\User\Http\Controllers\AuthController;
use Modules\User\Http\Controllers\SocialAuthController;
use Modules\User\Http\Controllers\UserController;

Route::prefix('v1/user')->name('api.')->group(function () {
    Route::post('login',    [AuthController::class, 'login']);
    Route::post('register', [AuthController::class, 'register']);

    // Email verification via OTP
    Route::post('email/verify', [AuthController::class, 'verifyEmailOtp']);
    Route::post('email/resend', [AuthController::class, 'resendEmailOtp']);
    Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('reset-password',  [AuthController::class, 'resetPassword']);


    // Social login (Google/GitHub/Facebook/One Tap)
    Route::prefix('social')->name('social.')->group(function () {
        Route::get('{provider}', [SocialAuthController::class, 'redirectToProvider'])->name('redirect');
        Route::get('{provider}/callback', [SocialAuthController::class, 'handleProviderCallback'])->name('callback');
        Route::post('google-onetap', [SocialAuthController::class, 'handleGoogleOneTap'])->name('google.one.tap');
    });

    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);

        Route::get('show',    [UserController::class, 'show']);
        Route::post('update', [UserController::class, 'update']);
        Route::delete('destroy', [UserController::class, 'destroy']);

        Route::post('notification-settings', [UserController::class, 'notificationSettings']);
        Route::post('change-password',       [UserController::class, 'changePassword']);

        // Yêu cầu xoá và huỷ yêu cầu xoá tài khoản
        Route::post('request-delete-account', [UserController::class, 'requestDeleteAccount']);
        Route::post('cancel-delete-account',  [UserController::class, 'cancelDeleteAccount']);
    });
});
