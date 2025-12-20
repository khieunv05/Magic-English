<?php

namespace Modules\User\Http\Requests\Authenticate;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'agree' => 'accepted',
            'heard_from' => 'required|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required.',
            'email.email' => 'The email format is invalid.',
            'email.unique' => 'This email has already been taken.',
            'password.required' => 'Password is required.',
            'password.min' => 'Password must be at least 8 characters.',
            'password.confirmed' => 'Password confirmation does not match.',
            'agree.accepted' => 'You must accept the terms and conditions.',
            'heard_from.required' => 'The Heard From is required',
            'heard_from.max' => 'The source name is too long.',
        ];
    }
}
