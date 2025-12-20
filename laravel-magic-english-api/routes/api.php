<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AddressController;
use App\Http\Controllers\GoogleOAuthController;

use App\Http\Controllers\RoomController;
use App\Http\Controllers\BuildingsController;
use App\Http\Controllers\PostsController;
use App\Http\Controllers\DistrictController;

// Phòng trọ
Route::prefix('room')->group(function () {
    Route::get('/', [RoomController::class, 'index']);
    Route::get('{room}', [RoomController::class, 'view']);
    Route::get('{room}/related', [RoomController::class, 'related']);
});

// Toà nhà
Route::prefix('buildings')->group(function () {
    Route::get('/', [BuildingsController::class, 'index']);
    Route::get('{building}', [BuildingsController::class, 'view']);
});

// Quận huyện
Route::prefix('district')->group(function () {
    Route::get('/', [DistrictController::class, 'index']);
    Route::get('{district}', [DistrictController::class, 'view']);
});

// Bài viết
Route::prefix('posts')->group(function () {
    Route::get('/', [PostsController::class, 'index']);
    Route::get('{post}', [PostsController::class, 'view']);
});


Route::prefix('address')->group(function () {
    Route::get('provinces', [AddressController::class, 'provinces']);
    Route::get('districts/{provinceCode}', [AddressController::class, 'districts']);
    Route::get('wards/{districtCode}', [AddressController::class, 'wards']);
});

Route::get('/oauth2callback', [GoogleOAuthController::class, 'callback']);
Route::get('/google/auth', [GoogleOAuthController::class, 'redirect']);
Route::get('/google/callback', [GoogleOAuthController::class, 'callback']);
