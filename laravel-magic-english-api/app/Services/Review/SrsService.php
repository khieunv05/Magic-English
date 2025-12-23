<?php

namespace App\Services\Review;

use Carbon\Carbon;
use App\Models\VocabularyReview;

class SrsService
{
  // SuperMemo-2 simplified
  public function review(VocabularyReview $review, int $grade): VocabularyReview
  {
    $grade = max(0, min(5, $grade));

    $ef = $review->ease_factor ?: 2.5;
    $rep = (int) $review->repetition;

    if ($grade < 3) {
      $rep = 0;
      $interval = 1;
    } else {
      $rep += 1;
      if ($rep == 1) {
        $interval = 1;
      } elseif ($rep == 2) {
        $interval = 6;
      } else {
        $interval = (int) round($review->interval_days * $ef);
        $interval = max($interval, 1);
      }
    }

    // Ease factor update
    $ef = $ef + (0.1 - (5 - $grade) * (0.08 + (5 - $grade) * 0.02));
    $ef = max(1.3, round($ef, 2));

    $review->repetition = $rep;
    $review->interval_days = $interval;
    $review->ease_factor = $ef;
    $review->last_grade = $grade;
    $review->last_reviewed_at = Carbon::now();
    $review->due_at = Carbon::now()->addDays($interval);
    $review->total_reviews = (int) $review->total_reviews + 1;

    return $review;
  }

  public function rememberNow(VocabularyReview $review): VocabularyReview
  {
    // Mark as remembered: boost interval and EF
    $review->repetition = max((int) $review->repetition, 3);
    $review->interval_days = max((int) $review->interval_days, 60);
    $review->ease_factor = max((float) $review->ease_factor, 2.5);
    $review->last_grade = 5;
    $review->last_reviewed_at = Carbon::now();
    $review->due_at = Carbon::now()->addDays($review->interval_days);
    $review->total_reviews = (int) $review->total_reviews + 1;
    return $review;
  }
}
