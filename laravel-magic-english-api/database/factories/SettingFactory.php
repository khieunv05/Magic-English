<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

use Modules\Admin\App\Models\Setting;

class SettingFactory extends Factory
{
    protected $model = Setting::class;

    public function definition(): array
    {
        return [
            'parent_id' => null,
            'name' => $this->faker->randomElement(['Cài đặt chung', 'Quy trình tự động', 'Báo cáo & phân tích', 'Hệ thống thông báo & liên lạc', 'Đơn hàng & thanh toán']),
            'slug' => $this->faker->unique()->slug,
            'description' => $this->faker->sentence,
            'order' => $this->faker->numberBetween(1, 10),
        ];
    }
}
