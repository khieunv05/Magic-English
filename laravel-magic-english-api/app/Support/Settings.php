<?php

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

if (! function_exists('get_setting_from_cache')) {
    function get_setting_from_cache(string $key, $default = null)
    {
        $cacheKey = 'settings.flat';

        $all = Cache::rememberForever($cacheKey, function () {
            return DB::table('setting_fields')
                ->select('slug', 'value')
                ->pluck('value', 'slug')
                ->toArray();
        });

        return $all[$key] ?? $default;
    }
}

if (! function_exists('forget_settings_cache')) {
    function forget_settings_cache(): void
    {
        Cache::forget('settings.flat');
    }
}
