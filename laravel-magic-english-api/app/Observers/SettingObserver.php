<?php

namespace App\Observers;

use Modules\Admin\Models\Setting;
use Illuminate\Support\Facades\Cache;

class SettingObserver
{
    public function created(): void
    {
        Cache::forget('settings');
    }

    public function updated(): void
    {
        Cache::forget('settings');
    }

    public function deleted(): void
    {
        Cache::forget('settings');
    }
}
