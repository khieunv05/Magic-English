<?php

namespace App\Http\Controllers;

use App\Models\GrammarCheck;
use App\Models\LearningActivity;
use App\Models\Vocabulary;
use App\Services\Tracking\TrackingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Arr;

class TrackingController extends Controller
{
  public function __construct(private readonly TrackingService $tracking)
  {
  }

  // FR3.1: List activities (auto-logged elsewhere)
  public function activities(Request $request)
  {
    $userId = Auth::id();
    $query = LearningActivity::query()
      ->where('user_id', $userId)
      ->with(['notebook:id,name'])
      ->orderByDesc('created_at');

    if ($request->filled('type')) {
      $query->where('type', $request->string('type'));
    }
    if ($request->filled('from')) {
      $query->where('created_at', '>=', $request->date('from'));
    }
    if ($request->filled('to')) {
      $query->where('created_at', '<=', $request->date('to'));
    }

    $items = $query->paginate($request->integer('per_page', 15));

    $activityList = collect($items->items());

    $vocabularyIds = $activityList
      ->filter(fn($a) => in_array($a->type, ['add_vocab', 'review_vocab'], true))
      ->pluck('related_id')
      ->filter()
      ->unique()
      ->values()
      ->all();

    $vocabulariesById = empty($vocabularyIds)
      ? collect()
      : Vocabulary::query()
        ->whereIn('id', $vocabularyIds)
        ->select([
          'id',
          'notebook_id',
          'word',
          'meaning',
          'part_of_speech',
          'cefr_level',
          'created_at',
        ])
        ->get()
        ->keyBy('id');

    $grammarCheckIds = $activityList
      ->filter(fn($a) => in_array($a->type, ['grammar_check'], true))
      ->pluck('related_id')
      ->filter()
      ->unique()
      ->values()
      ->all();

    $grammarChecksById = empty($grammarCheckIds)
      ? collect()
      : GrammarCheck::query()
        ->whereIn('id', $grammarCheckIds)
        ->where('user_id', $userId)
        ->select([
          'id',
          'user_id',
          'original_text',
          'score',
          'errors',
          'suggestions',
          'created_at',
        ])
        ->get()
        ->keyBy('id');

    $activityItems = $activityList->map(function ($activity) use ($vocabulariesById, $grammarChecksById) {
      $vocabulary = null;
      if (in_array($activity->type, ['add_vocab', 'review_vocab'], true) && $activity->related_id) {
        $vocab = $vocabulariesById->get($activity->related_id);
        if ($vocab) {
          $vocabulary = Arr::only($vocab->toArray(), [
            'id',
            'notebook_id',
            'word',
            'meaning',
            'part_of_speech',
            'cefr_level',
            'created_at',
          ]);
        }
      }

      $grammarCheck = null;
      if ($activity->type === 'grammar_check' && $activity->related_id) {
        $record = $grammarChecksById->get($activity->related_id);
        if ($record) {
          $errors = $record->errors ?? [];
          $suggestions = $record->suggestions ?? [];

          $grammarCheck = [
            'id' => $record->id,
            'score' => (int) $record->score,
            'original_text' => $record->original_text,
            'errors' => $errors,
            'suggestions' => $suggestions,
            'errors_count' => is_array($errors) ? count($errors) : 0,
            'suggestions_count' => is_array($suggestions) ? count($suggestions) : 0,
            'created_at' => $record->created_at,
          ];
        }
      }

      return [
        'id' => $activity->id,
        'user_id' => $activity->user_id,
        'notebook_id' => $activity->notebook_id,
        'type' => $activity->type,
        'related_id' => $activity->related_id,
        'activity_date' => $activity->activity_date,
        'created_at' => $activity->created_at,
        'updated_at' => $activity->updated_at,
        'notebook' => $activity->notebook ? [
          'id' => $activity->notebook->id,
          'name' => $activity->notebook->name,
        ] : null,
        'vocabulary' => $vocabulary,
        'grammar_check' => $grammarCheck,
      ];
    });

    return $this->apiResponse(true, 'Danh sách hoạt động', [
      'items' => $activityItems,
      'pagination' => [
        'total' => $items->total(),
        'per_page' => $items->perPage(),
        'current_page' => $items->currentPage(),
        'last_page' => $items->lastPage(),
      ],
    ]);
  }

  // FR3.2: Streak calculation
  public function streak()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Streak hiện tại', $this->tracking->getStreak($userId));
  }

  // FR3.3: Overview stats
  public function overview()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Tổng quan học tập', $this->tracking->getOverview($userId));
  }

  // FR3.4: Visualization data
  public function visualization()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Dữ liệu trực quan', $this->tracking->getVisualization($userId));
  }
}
