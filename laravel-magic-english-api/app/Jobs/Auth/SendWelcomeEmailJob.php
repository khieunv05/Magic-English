<?php

namespace App\Jobs\Auth;

use Throwable;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

use App\Services\Google\GmailService;

class SendWelcomeEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public string $email,
        public string $subject,
        public string $html
    ) {}

    public function handle(): void
    {
        try {
            app(GmailService::class)->sendMail($this->email, $this->subject, $this->html);
        } catch (Throwable $e) {
            logger()->error('Failed to send welcome email: ' . $e->getMessage(), ['email' => $this->email]);
        }
    }
}
