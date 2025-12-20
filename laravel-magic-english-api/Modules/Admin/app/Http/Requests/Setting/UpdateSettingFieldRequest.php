<?php

namespace Modules\Admin\Http\Requests\Setting;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateSettingFieldRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('id');

        return [
            'name' => ['required', 'string'],
            'slug' => [
                'required',
                'string',
                Rule::unique('setting_fields', 'slug')->ignore($id),
            ],
            'type' => [
                'required',
                Rule::in([
                    'text',
                    'textarea',
                    'select',
                    'multi-select',
                    'radio',
                    'checkbox',
                    'image',
                    'file',
                    'number',
                    'email',
                    'password',
                    'date-range',
                ]),
            ],
            'options' => ['nullable'],
            'value' => ['nullable'],
            'is_required' => ['boolean'],
            'placeholder' => ['nullable', 'string'],
            'description' => ['nullable', 'string'],
            'validation' => ['nullable'],
            'attributes' => ['nullable'],
            'order' => ['nullable', 'integer'],
        ];
    }
}
