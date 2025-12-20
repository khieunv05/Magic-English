<?php

namespace Modules\User\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()->id ?? null;

        return [
            'name'               => ['required', 'string', 'max:255'],
            'email'              => ['nullable', 'email', 'max:255', "unique:users,email,{$userId}"],
            'password'           => ['nullable', 'string', 'min:8'],
            'phone'              => ['nullable', 'string', 'max:20', "unique:users,phone,{$userId}"],
            'image'              => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],

            'dial_code'          => ['nullable', 'string', 'max:10'],
            'contact_method'     => ['nullable', 'in:telegram,whatsapp,email,phone'],
            'telegram_username'  => ['nullable', 'string', 'max:64'],
            'whatsapp_number'    => ['nullable', 'string', 'max:20'],
            'company_name'       => ['nullable', 'string', 'max:255'],
            'heard_from'         => ['nullable', 'string', 'max:255'],

            'birthday'           => ['nullable', 'date'],
            'gender'             => ['nullable', 'in:male,female,other'],
        ];
    }
}
