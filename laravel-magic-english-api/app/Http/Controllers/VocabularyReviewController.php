<?php

namespace App\Http\Controllers;

use App\Models\Vocabulary;
use App\Models\VocabularyReview;
use App\Services\Review\SrsService;
use App\Services\Tracking\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

class VocabularyReviewController extends Controller
{
  public function __construct(private readonly SrsService $srs)
  {
  }

  // Get due words for review
  public function due(Request $request)
  {
    $userId = Auth::id();
    $limit = max(1, min(100, (int) $request->integer('limit', 20)));
    $notebookId = $request->integer('notebook_id');

    $now = Carbon::now();

    $query = VocabularyReview::query()
      ->where('user_id', $userId)
      ->where(function ($q) use ($now) {
        $q->whereNull('due_at')->orWhere('due_at', '<=', $now);
      })
      ->with(['vocabulary']);

    if ($notebookId) {
      $query->whereHas('vocabulary', fn($q) => $q->where('notebook_id', $notebookId));
    }

    $items = $query->orderBy('due_at', 'asc')->limit($limit)->get();

    return $this->apiResponse(true, 'Danh sách từ cần ôn tập', [
      'items' => $items->map(function ($r) {
        return [
          'review_id' => $r->id,
          'vocabulary_id' => $r->vocabulary_id,
          'word' => $r->vocabulary->word,
          'meaning' => $r->vocabulary->meaning,
          'due_at' => $r->due_at,
          'repetition' => $r->repetition,
          'interval_days' => $r->interval_days,
        ];
      }),
    ]);
  }

  // Submit a review grade (0..5)
  public function answer(Request $request, Vocabulary $vocabulary)
  {
    $request->validate([
      'grade' => ['required', 'integer', Rule::in([0, 1, 2, 3, 4, 5])],
    ], [
      'grade.required' => 'Thiếu điểm đánh giá (0..5).',
      'grade.integer' => 'Điểm phải là số nguyên.',
      'grade.in' => 'Điểm hợp lệ 0..5.',
    ]);

    if ($vocabulary->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $userId = Auth::id();
    $review = VocabularyReview::firstOrCreate([
      'user_id' => $userId,
      'vocabulary_id' => $vocabulary->id,
    ]);

    $review = $this->srs->review($review, (int) $request->integer('grade'));
    $review->save();

    app(ActivityLogger::class)->log($userId, 'vocabulary_reviewed', [
      'vocabulary_id' => $vocabulary->id,
      'review_id' => $review->id,
      'grade' => $review->last_grade,
      'next_due_at' => $review->due_at,
      'interval_days' => $review->interval_days,
    ]);

    return $this->apiResponse(true, 'Cập nhật ôn tập thành công', [
      'review' => [
        'repetition' => $review->repetition,
        'interval_days' => $review->interval_days,
        'ease_factor' => $review->ease_factor,
        'last_grade' => $review->last_grade,
        'due_at' => $review->due_at,
      ],
    ]);
  }

  // Mark remembered now (boost interval)
  public function remember(Request $request, Vocabulary $vocabulary)
  {
    if ($vocabulary->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $userId = Auth::id();
    $review = VocabularyReview::firstOrCreate([
      'user_id' => $userId,
      'vocabulary_id' => $vocabulary->id,
    ]);

    $review = $this->srs->rememberNow($review);
    $review->save();

    app(ActivityLogger::class)->log($userId, 'vocabulary_remembered', [
      'vocabulary_id' => $vocabulary->id,
      'review_id' => $review->id,
      'next_due_at' => $review->due_at,
      'interval_days' => $review->interval_days,
    ]);

    return $this->apiResponse(true, 'Đánh dấu đã nhớ', [
      'review' => [
        'repetition' => $review->repetition,
        'interval_days' => $review->interval_days,
        'ease_factor' => $review->ease_factor,
        'last_grade' => $review->last_grade,
        'due_at' => $review->due_at,
      ],
    ]);
  }

  // Summary for dashboard widgets
  public function summary(Request $request)
  {
    $userId = Auth::id();
    $now = Carbon::now();

    $due = VocabularyReview::where('user_id', $userId)
      ->where(function ($q) use ($now) {
        $q->whereNull('due_at')->orWhere('due_at', '<=', $now); })
      ->count();
    $learning = VocabularyReview::where('user_id', $userId)->where('interval_days', '<', 21)->count();
    $mature = VocabularyReview::where('user_id', $userId)->where('interval_days', '>=', 21)->count();
    $total = VocabularyReview::where('user_id', $userId)->count();

    return $this->apiResponse(true, 'Tổng quan ôn tập', [
      'due' => $due,
      'learning' => $learning,
      'mature' => $mature,
      'total' => $total,
    ]);
  }
}
