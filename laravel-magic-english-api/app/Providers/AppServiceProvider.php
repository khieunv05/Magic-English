<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\PersonalAccessToken;
use Laravel\Sanctum\Sanctum;

use App\Models\User;
use App\Models\RoleUser;
use Modules\Admin\Models\SettingField;

use App\Observers\UserObserver;
use App\Observers\RoleUserObserver;
use App\Observers\SettingFieldObserver;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        try {
            config([
                'services.google.client_id'     => get_setting_from_cache('google_client_id'),
                'services.google.client_secret' => get_setting_from_cache('google_client_secret'),
                'services.google.redirect'      => get_setting_from_cache('google_redirect_uri'),
            ]);
        } catch (\Throwable $e) {
            Log::warning('Google config load failed: ' . $e->getMessage());
        }

        RateLimiter::for('telegram-global', function () {
            return Limit::perMinute(1200)->by('telegram-bot');
        });

        RateLimiter::for('telegram-chat', function ($job) {
            $chatId = property_exists($job, 'chatId') ? $job->chatId : 'unknown';
            return Limit::perMinute(60)->by('chat:' . $chatId);
        });

        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);

        User::observe(UserObserver::class);
        RoleUser::observe(RoleUserObserver::class);
        SettingField::observe(SettingFieldObserver::class);
    }
}
