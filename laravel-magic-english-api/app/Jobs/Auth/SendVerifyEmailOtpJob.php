<?php

namespace App\Jobs\Auth;

use Throwable;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

use App\Services\Google\GmailService;

class SendVerifyEmailOtpJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected string $email;
    protected string $subject;
    protected string $html;

    public function __construct(string $email, string $subject, string $html)
    {
        $this->email = $email;
        $this->subject = $subject;
        $this->html = $html;
    }

    public function handle(): void
    {
        try {
            app(GmailService::class)->sendMail(
                $this->email,
                $this->subject,
                $this->html
            );
        } catch (Throwable $e) {
            logger()->error('Failed to send verify OTP email: ' . $e->getMessage(), [
                'email' => $this->email,
            ]);
        }
    }
}
