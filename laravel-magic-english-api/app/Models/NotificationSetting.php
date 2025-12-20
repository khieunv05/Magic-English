<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationSetting extends Model
{
    public $timestamps = false;
    protected $table = "notification_settings";
    protected $fillable = [
        'user_id',
        'google_notification_token',
        'telegram_chat_id',
        'telegram_bot_token',
        'telegram_notifications_enabled',
        'google_notifications_enabled',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
