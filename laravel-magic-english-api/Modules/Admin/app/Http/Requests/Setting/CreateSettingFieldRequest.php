<?php

namespace Modules\Admin\Http\Requests\Setting;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateSettingFieldRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'group_id' => ['required', 'exists:settings,id'],
            'name' => ['required', 'string'],
            'slug' => ['nullable', 'string', 'unique:setting_fields,slug'],
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

    public function attributes(): array
    {
        return [
            'name' => 'Tên trường',
            'slug' => 'Slug',
            'group_id' => 'Nhóm cài đặt',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Vui lòng nhập tên trường.',
            'slug.required' => 'Vui lòng nhập slug.',
            'slug.unique' => 'Slug này đã tồn tại.',
            'type.in' => 'Loại không hợp lệ.',
        ];
    }
}
