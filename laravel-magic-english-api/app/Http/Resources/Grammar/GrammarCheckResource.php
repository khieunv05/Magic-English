<?php

namespace App\Http\Resources\Grammar;

use Illuminate\Http\Resources\Json\JsonResource;

class GrammarCheckResource extends JsonResource
{
  public function toArray($request)
  {
    return [
      'id' => $this->id,
      'user_id' => $this->user_id,
      'original_text' => $this->original_text,
      'score' => (int) $this->score,
      'errors' => $this->errors ?? [],
      'suggestions' => $this->suggestions ?? [],
      'created_at' => $this->created_at,
      'updated_at' => $this->updated_at,
    ];
  }
}
