<?php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class VocabularyFactory extends Factory
{
  public function definition(): array
  {
    return [
      'word' => fake()->unique()->word(),
      'ipa' => '/' . fake()->word() . '/',
      'meaning' => fake()->sentence(3),
      'part_of_speech' => fake()->randomElement(['noun', 'verb', 'adj', 'adv']),
      'example' => fake()->sentence(),
      'cefr_level' => fake()->randomElement(['A1', 'A2', 'B1', 'B2', 'C1']),
      'review_count' => 0,
      'last_reviewed_at' => null,
    ];
  }
}
