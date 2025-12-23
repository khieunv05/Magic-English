@component('mail::message')
# Welcome {{ $user->name }},

Thank you for registering with **BlueMedia**.

Your account has been successfully created and is now active.
You can start using our advertising account rental services right away.

If you have any questions or need assistance, our support team is here to help.

We look forward to supporting your campaigns,
{{ config('app.name') }}
@endcomponent
