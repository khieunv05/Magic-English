<?php

namespace App\Services\Tracking;

use App\Models\LearningActivity;
use App\Models\Vocabulary;

class ActivityLogger
{
  public function log(int $userId, string $type, array $data = []): void
  {
    // Map internal event names to enum values in legacy schema
    $typeMap = [
      'vocabulary_added' => 'add_vocab',
      'vocabulary_reviewed' => 'review_vocab',
      'vocabulary_remembered' => 'review_vocab',
      'grammar_scored' => 'grammar_check',
    ];
    $enumType = $typeMap[$type] ?? 'grammar_check';

    $relatedId = $data['vocabulary_id'] ?? ($data['grammar_check_id'] ?? ($data['review_id'] ?? null));
    $notebookId = $data['notebook_id'] ?? null;

    // Enrich notebook_id from Vocabulary if possible
    if (!$notebookId && isset($data['vocabulary_id'])) {
      $vocab = Vocabulary::query()->select(['id', 'notebook_id'])->find($data['vocabulary_id']);
      if ($vocab) {
        $notebookId = $vocab->notebook_id;
      }
    }

    LearningActivity::create([
      'user_id' => $userId,
      'notebook_id' => $notebookId,
      'type' => $enumType,
      'related_id' => $relatedId,
      'activity_date' => now()->toDateString(),
    ]);
  }
}
