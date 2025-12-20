<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

use App\Models\User;

class ForgotPasswordMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public User $user;
    public string $token;
    public ?string $resetUrl;
    public int $ttlMinutes;

    /**
     * @param User   $user
     * @param string $token
     * @param string|null $resetUrl
     * @param int    $ttlMinutes
     */
    public function __construct(User $user, string $token, ?string $resetUrl = null, int $ttlMinutes = 60)
    {
        $this->user       = $user;
        $this->token      = $token;
        $this->resetUrl   = $resetUrl;
        $this->ttlMinutes = $ttlMinutes;
    }

    public function build(): ForgotPasswordMail
    {
        $url = $this->resetUrl ?: rtrim((string) config('app.frontend_url'), '/')
            . '/reset-password?token=' . urlencode($this->token)
            . '&email=' . urlencode($this->user->email);

        return $this->subject('Password reset request')
            ->markdown('emails.users.forgot_password', [
                'user'        => $this->user,
                'resetUrl'    => $url,
                'ttlMinutes'  => $this->ttlMinutes,
            ]);
    }
}
