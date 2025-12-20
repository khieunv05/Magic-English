<?php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class VocabularyReviewFactory extends Factory
{
  public function definition(): array
  {
    return [
      'result' => fake()->randomElement(['remembered', 'forgot']),
      'reviewed_at' => fake()->dateTimeThisMonth(),
    ];
  }
}
