<?php

use Illuminate\Support\Facades\Route;
use Modules\Admin\Http\Controllers\AdminController;
use Modules\Admin\Http\Controllers\AuthController;
use Modules\Admin\Http\Controllers\BuilderController;
use Modules\Admin\Http\Controllers\BuilderItemController;
use Modules\Admin\Http\Controllers\BookingController;
use Modules\Admin\Http\Controllers\BuildingsController;
use Modules\Admin\Http\Controllers\CategoryController;
use Modules\Admin\Http\Controllers\CustomerController;
use Modules\Admin\Http\Controllers\DistrictController;
use Modules\Admin\Http\Controllers\ImageController;
use Modules\Admin\Http\Controllers\NotificationController;
use Modules\Admin\Http\Controllers\PageController;
use Modules\Admin\Http\Controllers\PostController;
use Modules\Admin\Http\Controllers\RoomController;
use Modules\Admin\Http\Controllers\SettingController;
use Modules\Admin\Http\Controllers\SettingFieldController;
use Modules\User\Http\Controllers\UserController;

Route::middleware(['auth:sanctum'])->prefix('v1/admin')->name('api.admin.')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->withoutMiddleware(['auth:sanctum']);
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AdminController::class, 'Me']);

    Route::apiResource('room', RoomController::class);
    Route::apiResource('post', PostController::class);
    Route::apiResource('page', PageController::class);
    Route::apiResource('admin', AdminController::class);
    Route::apiResource('customer', CustomerController::class);
    Route::apiResource('user', UserController::class);
    Route::apiResource('buildings', BuildingsController::class);
    Route::apiResource('booking', BookingController::class);
    Route::apiResource('district', DistrictController::class);
    Route::apiResource('category', CategoryController::class);
    Route::apiResource('builder', BuilderController::class);
    Route::apiResource('builder.items', BuilderItemController::class);
    Route::post('builder/{builder}/order', [BuilderController::class, 'updateOrder']);

    // Upload file
    Route::post('upload', [ImageController::class, 'upload']);
    Route::post('uploads', [ImageController::class, 'uploads']);

    // Settings
    Route::prefix('settings')->name('settings.')->group(function () {
        Route::apiResource('/', SettingController::class);
        Route::put('update-all', [SettingController::class, 'updateAll']);
        Route::post('update-order', [SettingController::class, 'updateOrder']);
        Route::post('update-field-order', [SettingController::class, 'updateFieldOrder']);

        Route::prefix('fields')->name('fields.')->group(function () {
            Route::post('/', [SettingFieldController::class, 'store']);
            Route::put('/{id}', [SettingFieldController::class, 'update']);
            Route::delete('/{id}', [SettingFieldController::class, 'destroy']);
        });
    });

    // Notifications
    Route::prefix('notifications')->name('notifications.')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::post('{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('read-all', [NotificationController::class, 'markAllAsRead']);
        Route::delete('{id}', [NotificationController::class, 'destroy']);
    });
});
