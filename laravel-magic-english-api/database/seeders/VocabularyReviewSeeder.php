<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Vocabulary;
use App\Models\VocabularyReview;

class VocabularyReviewSeeder extends Seeder
{
  public function run(): void
  {
    Vocabulary::all()->each(function ($vocab) {
      VocabularyReview::factory()->count(rand(1, 3))->create([
        'vocabulary_id' => $vocab->id,
        'user_id' => $vocab->user_id,
      ]);
    });
  }
}
