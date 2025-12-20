<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

use App\Models\User;
use App\Models\Wallet\Wallet;
use App\Models\NotificationSetting;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::insert([
            [
                'name' => 'Hoàng Lân',
                'email' => 'hoanglan@gmail.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
                'image' => null,
                'status' => 'active',
                'gender' => 'male',
                'is_staff' => 'staff',
                'username' => 'SUPER001',
                'code' => 'SUPER001',
                'phone' => '0900000002',
                'description' => 'Tài khoản cao nhất hệ thống',
                'wallet_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Văn Khiếu',
                'email' => 'vankhieu@gmail.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
                'image' => null,
                'status' => 'active',
                'gender' => 'male',
                'is_staff' => 'staff',
                'username' => 'ADMIN001',
                'code' => 'ADMIN001',
                'phone' => '0900000001',
                'description' => 'Tài khoản quản trị viên',
                'wallet_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Văn Séc',
                'email' => 'vansec@gmail.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
                'image' => null,
                'status' => 'active',
                'gender' => 'male',
                'is_staff' => 'user',
                'username' => 'usertest',
                'code' => 'usertest',
                'phone' => '0900000003',
                'description' => 'Tài khoản người dùng thử nghiệm',
                'wallet_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $users = User::whereIn('email', [
            'hoanglan@gmail.com',
            'vankhieu@gmail.com',
            'vansec@gmail.com'
        ])->get();


    }
}
