@component('mail::message')
# Congratulations {{ $user->name }},

Your account has been successfully approved.
You can now log in and start using all the features of **BlueMedia**.

@component('mail::button', ['url' => config('app.frontend_url') . '/auth/user/login'])
Log in now
@endcomponent

If you did not request this registration, please ignore this email.

Welcome aboard,
{{ config('app.name') }}
@endcomponent
