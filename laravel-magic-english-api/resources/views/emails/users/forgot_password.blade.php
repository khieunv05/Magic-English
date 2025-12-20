@component('mail::message')
# Reset Your Password

Hello {{ $user->name ?? 'there' }},

We received a request to reset the password for your account.
Click the button below to set a new password.

@component('mail::button', ['url' => $resetUrl])
Reset Password
@endcomponent

Or copy and paste the following link into your browser:

{{ $resetUrl }}

> This link will expire in {{ $ttlMinutes ?? 60 }} minutes.

If you did not request a password reset, please ignore this email.

Thanks,
{{ config('app.name') }}
@endcomponent
