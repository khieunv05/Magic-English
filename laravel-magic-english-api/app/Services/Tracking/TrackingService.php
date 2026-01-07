<?php

namespace App\Services\Tracking;

use App\Models\LearningActivity;
use App\Models\User;
use App\Models\Vocabulary;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class TrackingService
{
  public function __construct()
  {
  }

  public function getStreak(int $userId): array
  {
    // Fetch distinct activity dates for the user
    $dates = LearningActivity::query()
      ->where('user_id', $userId)
      ->orderByDesc('created_at')
      ->pluck('created_at')
      ->map(fn($dt) => Carbon::parse($dt)->toDateString())
      ->unique()
      ->values()
      ->all();

    $today = Carbon::today()->toDateString();
    $streak = 0;
    $cursor = Carbon::today();

    // If no activity, streak is 0
    if (empty($dates)) {
      return [
        'streak' => 0,
        'today_active' => false,
        'last_active_date' => null,
      ];
    }

    // Build a set for O(1) membership checks
    $dateSet = array_flip($dates);

    // Count consecutive days ending today (or from last active day if today inactive)
    $todayActive = isset($dateSet[$today]);
    $start = $todayActive ? Carbon::today() : Carbon::parse($dates[0]);

    $cursor = $start->copy();
    while (isset($dateSet[$cursor->toDateString()])) {
      $streak++;
      $cursor->subDay();
    }

    return [
      'streak' => $streak,
      'today_active' => $todayActive,
      'last_active_date' => $dates[0] ?? null,
    ];
  }

  public function getOverview(int $userId): array
  {
    $user = User::query()->select(['id', 'created_at'])->find($userId);
    $totalDaysJoined = null;
    if ($user?->created_at) {
      $joinedAt = Carbon::parse($user->created_at)->startOfDay();
      $today = Carbon::today();
      // Inclusive count: if joined today => 1 day
      $totalDaysJoined = $joinedAt->diffInDays($today) + 1;
    }

    $totalVocab = Vocabulary::query()->where('user_id', $userId)->count();
    $streakInfo = $this->getStreak($userId);
    $streak = $streakInfo['streak'];

    $badges = [];
    foreach ([3, 7, 30] as $threshold) {
      if ($streak >= $threshold) {
        $badges[] = [
          'name' => "Streak ${threshold} ngày",
          'achieved' => true,
        ];
      } else {
        $badges[] = [
          'name' => "Streak ${threshold} ngày",
          'achieved' => false,
        ];
      }
    }

    return [
      'total_days_joined' => $totalDaysJoined,
      'total_vocabulary_learned' => $totalVocab,
      'streak' => $streakInfo,
      'badges' => $badges,
    ];
  }

  public function getVisualization(int $userId): array
  {
    // Pie: part_of_speech distribution
    $pos = Vocabulary::query()
      ->where('user_id', $userId)
      ->select('part_of_speech', DB::raw('COUNT(*) as count'))
      ->groupBy('part_of_speech')
      ->pluck('count', 'part_of_speech')
      ->toArray();

    // Bar: CEFR distribution
    $cefr = Vocabulary::query()
      ->where('user_id', $userId)
      ->select('cefr_level', DB::raw('COUNT(*) as count'))
      ->groupBy('cefr_level')
      ->pluck('count', 'cefr_level')
      ->toArray();

    // Ensure keys exist even if zero
    $cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    foreach ($cefrLevels as $lvl) {
      if (!isset($cefr[$lvl])) {
        $cefr[$lvl] = 0;
      }
    }

    return [
      'pie_part_of_speech' => $pos,
      'bar_cefr_level' => $cefr,
    ];
  }
}
