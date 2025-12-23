<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AddressController;
use App\Http\Controllers\GoogleOAuthController;

use App\Http\Controllers\RoomController;
use App\Http\Controllers\BuildingsController;
use App\Http\Controllers\PostsController;
use App\Http\Controllers\DistrictController;
use App\Http\Controllers\NotebookController;
use App\Http\Controllers\VocabularyController;
use App\Http\Controllers\Ai\WritingScoreController;
use App\Http\Controllers\GrammarCheckController;
use App\Http\Controllers\TrackingController;

// Phòng trọ
Route::prefix('room')->group(function () {
    Route::get('/', [RoomController::class, 'index']);
    Route::get('{room}', [RoomController::class, 'view']);
    Route::get('{room}/related', [RoomController::class, 'related']);
});

// AI Writing analysis (protected or open depending on usage). Here: protected
Route::middleware(['auth:sanctum'])->prefix('ai')->group(function () {
    Route::post('writing-score/analyze', [WritingScoreController::class, 'analyze']);
    Route::post('writing-score/analyze-ollama', [WritingScoreController::class, 'analyzeOllama']);
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

// Notebooks (protected)
Route::middleware(['auth:sanctum'])->prefix('notebooks')->group(function () {
    Route::get('/', [NotebookController::class, 'index']);
    Route::post('/', [NotebookController::class, 'store']);
    Route::get('{notebook}', [NotebookController::class, 'show']);
    Route::put('{notebook}', [NotebookController::class, 'update']);
    Route::patch('{notebook}', [NotebookController::class, 'update']);
    Route::delete('{notebook}', [NotebookController::class, 'destroy']);

    // Vocabularies nested under a notebook
    Route::get('{notebook}/vocabularies', [VocabularyController::class, 'index']);
    Route::post('{notebook}/vocabularies', [VocabularyController::class, 'store']);
});

// Vocabularies by id (protected)
Route::middleware(['auth:sanctum'])->prefix('vocabularies')->group(function () {
    Route::get('{vocabulary}', [VocabularyController::class, 'show']);
    Route::put('{vocabulary}', [VocabularyController::class, 'update']);
    Route::patch('{vocabulary}', [VocabularyController::class, 'update']);
    Route::delete('{vocabulary}', [VocabularyController::class, 'destroy']);
});

// Grammar checks (protected)
Route::middleware(['auth:sanctum'])->prefix('grammar-checks')->group(function () {
    Route::post('/', [GrammarCheckController::class, 'store']);
    Route::post('{grammarCheck}/rescore', [GrammarCheckController::class, 'rescore']);
    Route::get('/', [GrammarCheckController::class, 'index']);
    Route::get('{grammarCheck}', [GrammarCheckController::class, 'show']);
    Route::delete('{grammarCheck}', [GrammarCheckController::class, 'destroy']);
});

// Tracking (protected)
Route::middleware(['auth:sanctum'])->prefix('tracking')->group(function () {
    // FR3.1: Activities list
    Route::get('activities', [TrackingController::class, 'activities']);
    // FR3.2: Streak
    Route::get('streak', [TrackingController::class, 'streak']);
    // FR3.3: Overview
    Route::get('overview', [TrackingController::class, 'overview']);
    // FR3.4: Visualization
    Route::get('visualization', [TrackingController::class, 'visualization']);
});
