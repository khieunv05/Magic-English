<?php

namespace App\Observers;

use Illuminate\Support\Facades\Cache;
use Modules\Admin\app\Models\SettingField;

class SettingFieldObserver
{
    public function created(SettingField $setting): void
    {
        Cache::forget('settings');
        Cache::forget('setting_from_cache');
    }

    public function updated(SettingField $setting): void
    {
        Cache::forget('settings');
        Cache::forget('setting_from_cache');
    }

    public function deleted(SettingField $setting): void
    {
        Cache::forget('settings');
        Cache::forget('setting_from_cache');
    }
}
