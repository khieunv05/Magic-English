<?php

namespace Modules\User\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Carbon;

class UpdateUserRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        $birthday = $this->input('birthday');
        if (is_string($birthday) && trim($birthday) !== '') {
            $normalizedBirthday = $this->normalizeBirthday($birthday);
            if ($normalizedBirthday !== null) {
                $this->merge(['birthday' => $normalizedBirthday]);
            }
        }

        $gender = $this->input('gender');

        if ($gender !== null && $gender !== '') {
            $normalized = $this->normalizeGender($gender);
            if ($normalized !== null) {
                $this->merge(['gender' => $normalized]);
            }
        }
    }

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()->id ?? null;

        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255', "unique:users,email,{$userId}"],
            'password' => ['nullable', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:20', "unique:users,phone,{$userId}"],
            // Backward compatible: accept both `image` and `avatar`
            'image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'avatar' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],

            'dial_code' => ['nullable', 'string', 'max:10'],
            'contact_method' => ['nullable', 'in:telegram,whatsapp,email,phone'],
            'telegram_username' => ['nullable', 'string', 'max:64'],
            'whatsapp_number' => ['nullable', 'string', 'max:20'],
            'company_name' => ['nullable', 'string', 'max:255'],
            'heard_from' => ['nullable', 'string', 'max:255'],

            'birthday' => ['nullable', 'date'],
            // `gender` is normalized in prepareForValidation() to match enum values
            'gender' => ['nullable', 'in:male,female,other'],
        ];
    }

    private function normalizeBirthday(string $birthday): ?string
    {
        $value = trim($birthday);

        // Accept dd/mm/yyyy -> normalize to yyyy-mm-dd
        if (preg_match('/^\d{1,2}\/\d{1,2}\/\d{4}$/', $value)) {
            try {
                return Carbon::createFromFormat('d/m/Y', $value)->toDateString();
            } catch (\Throwable) {
                return null;
            }
        }

        return null;
    }

    private function normalizeGender(mixed $gender): ?string
    {
        if (!is_string($gender)) {
            return null;
        }

        $value = trim(mb_strtolower($gender));
        return match ($value) {
            'nam', 'male' => 'male',
            'nu', 'nữ', 'nư', 'female' => 'female',
            'other' => 'other',
            default => null,
        };
    }
}
