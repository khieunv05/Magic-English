<?php

namespace App\Observers;

use Throwable;
use Illuminate\Support\Facades\Log;

use App\Models\User;
use App\Models\Wallet\Wallet;
use App\Models\NotificationSetting;

class UserObserver
{
    public function created(User $user): void
    {
        $wallet = Wallet::create([
            'user_id' => $user->id,
            'balance' => 0,
        ]);

        NotificationSetting::create([
            'user_id' => $user->id,
            'telegram_notifications_enabled' => false,
            'google_notifications_enabled'   => false,
        ]);

        try {
            $user->forceFill([
                'wallet_id'      => $wallet->id,
            ])->saveQuietly();
        } catch (Throwable $e) {
            Log::warning('Assign default service fee failed: ' . $e->getMessage());
        }
    }
}
