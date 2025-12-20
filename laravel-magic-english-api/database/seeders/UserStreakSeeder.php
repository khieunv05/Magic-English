<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\UserStreak;

class UserStreakSeeder extends Seeder
{
  public function run(): void
  {
    User::all()->each(function ($user) {
      UserStreak::create([
        'user_id' => $user->id,
        'current_streak' => rand(1, 5),
        'longest_streak' => rand(5, 20),
        'last_activity_date' => now()->subDay(),
      ]);
    });
  }
}
