<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('setting_fields')->truncate();
        DB::table('settings')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $settings = [
            [
                'id' => 1,
                'name' => 'Hệ thống',
                'slug' => 'system',
                'description' => 'Cấu hình hệ thống',
                'parent_id' => null,
                'order' => 2,
            ],
            [
                'id' => 2,
                'name' => 'Google',
                'slug' => 'system-google',
                'description' => 'Cấu hình hệ thống google',
                'parent_id' => 1,
                'order' => 1,
            ],
            [
                'id' => 3,
                'name' => 'Quy trình tự động',
                'slug' => 'system-settings',
                'description' => 'Cấu hình hệ thống',
                'parent_id' => null,
                'order' => 1,
            ],
            [
                'id' => 4,
                'name' => 'Account Agency',
                'slug' => 'account-agency',
                'description' => 'Cấu hình cho thuê loại tài khoản quảng cáo',
                'parent_id' => 1,
                'order' => 1,
            ],
            [
                'id' => 5,
                'name' => 'Quản lý thông báo',
                'slug' => 'notifications',
                'description' => 'Cấu hình gửi thông báo',
                'parent_id' => null,
                'order' => 2,
            ],
            [
                'id' => 6,
                'name' => 'Telegram',
                'slug' => 'notifications-telegram',
                'description' => 'Cấu hình gửi tin nhắn qua Telegram',
                'parent_id' => 3,
                'order' => 1,
            ],
        ];

        foreach ($settings as $setting) {
            $settingId = DB::table('settings')->insertGetId(
                array_merge($setting, ['created_at' => now(), 'updated_at' => now()])
            );

            $fields = $this->getSettingFields($setting['slug']);
            foreach ($fields as $field) {
                DB::table('setting_fields')->insert(
                    array_merge($field, [
                        'group_id' => $settingId,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ])
                );
            }
        }
    }

    private function getSettingFields(string $slug): array
    {
        $fieldsMap = [
            'system-google' => [
                [
                    'name' => 'Google Client ID',
                    'slug' => 'google_client_id',
                    'type' => 'text',
                    'options' => null,
                    'value' => '279996431200-nkut1okcnk1tkv50ud52p29oubp5bojm.apps.googleusercontent.com',
                    'is_required' => true,
                    'placeholder' => 'Nhập GOOGLE_CLIENT_ID',
                    'description' => 'Client ID từ Google Cloud (OAuth 2.0)',
                    'validation' => json_encode(['required' => true, 'string' => true]),
                    'attributes' => null,
                    'order' => 1,
                ],
                [
                    'name' => 'Google Client Secret',
                    'slug' => 'google_client_secret',
                    'type' => 'text',
                    'options' => null,
                    'value' => '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',
                    'is_required' => true,
                    'placeholder' => 'Nhập GOOGLE_CLIENT_SECRET',
                    'description' => 'Client Secret từ Google Cloud (OAuth 2.0)',
                    'validation' => json_encode(['required' => true, 'string' => true]),
                    'attributes' => null,
                    'order' => 2,
                ],
                [
                    'name' => 'Google Redirect URI',
                    'slug' => 'google_redirect_uri',
                    'type' => 'text',
                    'options' => null,
                    'value' => 'http://localhost:8000/api/v1/user/social/google/callback',
                    'is_required' => true,
                    'placeholder' => 'Nhập GOOGLE_REDIRECT_URI',
                    'description' => 'Redirect URI khai báo trong Google Cloud (khớp tuyệt đối)',
                    'validation' => json_encode(['required' => true, 'url' => true]),
                    'attributes' => null,
                    'order' => 3,
                ],
                [
                    'name' => 'Google Gmail Redirect URI',
                    'slug' => 'google_gmail_redirect_uri',
                    'type' => 'text',
                    'options' => null,
                    'value' => 'http://localhost:8000/api/google/callback',
                    'is_required' => true,
                    'placeholder' => 'Nhập GOOGLE_GMAIL_REDIRECT_URI',
                    'description' => 'Redirect URI dành riêng cho Gmail API (dùng để gửi mail qua Gmail Service)',
                    'validation' => json_encode(['required' => true, 'url' => true]),
                    'attributes' => null,
                    'order' => 4,
                ],
            ],

            'notifications-telegram' => [
                [
                    'name' => 'Telegram Bot Token',
                    'slug' => 'telegram_bot_token',
                    'type' => 'text',
                    'options' => null,
                    'value' => '7723357778:AAEUxRLv4TrlcRa1oek_7ALu_OR-mhasZZ8',
                    'is_required' => true,
                    'placeholder' => 'Nhập Telegram Bot Token',
                    'description' => 'Token của bot Telegram để gửi tin nhắn',
                    'validation' => json_encode(['required' => true, 'string' => true]),
                    'attributes' => null,
                    'order' => 1,
                ],
                [
                    'name' => 'Chat ID - Nhật ký hoạt động',
                    'slug' => 'telegram_chat_id_activity',
                    'type' => 'text',
                    'options' => null,
                    'value' => '-4815972972',
                    'is_required' => true,
                    'placeholder' => 'VD: -1001234567890',
                    'description' => 'Chat ID nhận thông báo hoạt động (activity)',
                    'validation' => json_encode(['required' => true, 'string' => true]),
                    'attributes' => null,
                    'order' => 2,
                ],
                [
                    'name' => 'Chat ID - Số dư',
                    'slug' => 'telegram_chat_id_balance',
                    'type' => 'text',
                    'options' => null,
                    'value' => '-4914934302',
                    'is_required' => true,
                    'placeholder' => 'VD: -1009876543210',
                    'description' => 'Chat ID nhận thông báo số dư (balance)',
                    'validation' => json_encode(['required' => true, 'string' => true]),
                    'attributes' => null,
                    'order' => 3,
                ],
                [
                    'name' => 'Ngưỡng spam (tin/phút)',
                    'slug' => 'telegram_spam_threshold_per_min',
                    'type' => 'number',
                    'options' => null,
                    'value' => '20',
                    'is_required' => true,
                    'placeholder' => 'Ví dụ: 20',
                    'description' => 'Tối đa số tin nhắn mỗi phút trước khi bị block',
                    'validation' => json_encode(['required' => true, 'numeric' => true, 'min' => 1]),
                    'attributes' => null,
                    'order' => 10,
                ],
                [
                    'name' => 'Thời gian block (phút)',
                    'slug' => 'telegram_block_minutes',
                    'type' => 'number',
                    'options' => null,
                    'value' => '10',
                    'is_required' => true,
                    'placeholder' => 'Ví dụ: 10',
                    'description' => 'Số phút sẽ chặn gửi nếu vượt ngưỡng spam',
                    'validation' => json_encode(['required' => true, 'numeric' => true, 'min' => 1]),
                    'attributes' => null,
                    'order' => 11,
                ],
            ],
        ];

        return $fieldsMap[$slug] ?? [];
    }
}
