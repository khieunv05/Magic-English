<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\GrammarCheck;

class GrammarCheckSeeder extends Seeder
{
  public function run(): void
  {
    User::all()->each(function ($user) {
      GrammarCheck::factory()->count(3)->create([
        'user_id' => $user->id,
      ]);
    });
  }
}
