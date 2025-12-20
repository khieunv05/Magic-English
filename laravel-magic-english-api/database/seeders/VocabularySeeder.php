<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Notebook;
use App\Models\Vocabulary;

class VocabularySeeder extends Seeder
{
  public function run(): void
  {
    Notebook::all()->each(function ($notebook) {
      Vocabulary::factory()->count(10)->create([
        'user_id' => $notebook->user_id,
        'notebook_id' => $notebook->id,
      ]);
    });
  }
}
