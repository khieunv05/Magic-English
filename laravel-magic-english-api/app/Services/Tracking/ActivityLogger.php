<?php

namespace App\Services\Tracking;

use App\Models\LearningActivity;

class ActivityLogger
{
  public function log(int $userId, string $type, array $data = []): void
  {
    LearningActivity::create([
      'user_id' => $userId,
      'type' => $type,
      'data' => $data,
    ]);
  }
}
