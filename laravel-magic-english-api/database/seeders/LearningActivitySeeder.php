<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Vocabulary;
use App\Models\LearningActivity;

class LearningActivitySeeder extends Seeder
{
  public function run(): void
  {
    Vocabulary::all()->each(function ($vocab) {
      LearningActivity::create([
        'user_id' => $vocab->user_id,
        'notebook_id' => $vocab->notebook_id,
        'type' => 'add_vocab',
        'related_id' => $vocab->id,
        'activity_date' => now()->toDateString(),
      ]);
    });
  }
}
