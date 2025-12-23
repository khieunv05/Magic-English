<?php

namespace App\Http\Resources\Vocabulary;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;
use App\Http\Resources\User\UserResource;
use App\Http\Resources\Notebook\NotebookResource;

class VocabularyResource extends JsonResource
{
  public function toArray($request): array
  {
    return [
      'id' => $this->id,
      'word' => $this->word,
      'ipa' => $this->ipa,
      'meaning' => $this->meaning,
      'part_of_speech' => $this->part_of_speech,
      'example' => $this->example,
      'cefr_level' => $this->cefr_level,
      'review_count' => (int) $this->review_count,
      'last_reviewed_at' => $this->last_reviewed_at,

      'user' => new UserResource($this->whenLoaded('user')),
      'notebook' => new NotebookResource($this->whenLoaded('notebook')),

      'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
      'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
    ];
  }
}
