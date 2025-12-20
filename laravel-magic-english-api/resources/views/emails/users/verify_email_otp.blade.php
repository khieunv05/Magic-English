@component('mail::message')
# Verify your email

Hi {{ $user->name ?? 'there' }},

Your verification code is:

@component('mail::panel')
<strong style="font-size:24px;letter-spacing:3px">{{ $otp }}</strong>
@endcomponent

This code expires in {{ $ttlMinutes }} minutes.

If you didn't sign up, you can ignore this email.

Thanks,<br>
{{ config('app.name') }}
@endcomponent
