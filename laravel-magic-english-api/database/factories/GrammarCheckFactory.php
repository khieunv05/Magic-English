<?php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class GrammarCheckFactory extends Factory
{
  public function definition(): array
  {
    return [
      'original_text' => fake()->paragraph(),
      'score' => fake()->numberBetween(4, 9),
      'errors' => [],
      'suggestions' => [],
    ];
  }
}
