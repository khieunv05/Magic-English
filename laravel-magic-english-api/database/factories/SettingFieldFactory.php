<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

use Modules\Admin\App\Models\SettingField;
use Modules\Admin\App\Models\Setting;

class SettingFieldFactory extends Factory
{
    protected $model = SettingField::class;

    public function definition(): array
    {
        return [
            'group_id' => Setting::inRandomOrder()->first()->id,
            'name' => $this->faker->sentence(3),
            'slug' => $this->faker->unique()->slug,
            'type' => $this->faker->randomElement(['text', 'textarea', 'select', 'radio', 'checkbox', 'image']),
            'options' => json_encode(['Option 1', 'Option 2', 'Option 3']),
            'value' => $this->faker->word,
            'is_required' => $this->faker->boolean,
            'order' => $this->faker->numberBetween(1, 10),
        ];
    }
}
