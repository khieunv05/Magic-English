<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

use App\Models\User;

class VerifyEmailOtpMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public User $user;
    public string $otp;
    public ?int $ttlMinutes;

    public function __construct(User $user, string $otp, ?int $ttlMinutes = 10)
    {
        $this->user = $user;
        $this->otp = $otp;
        $this->ttlMinutes = $ttlMinutes;
    }

    public function build()
    {
        return $this->subject('Verify your email')
            ->markdown('emails.users.verify_email_otp', [
                'user' => $this->user,
                'otp' => $this->otp,
                'ttlMinutes' => $this->ttlMinutes,
            ]);
    }
}
