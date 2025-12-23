<?php

namespace Modules\Admin\Http\Requests\Setting;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SettingRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'group' => ['nullable', 'string'], // thường dùng nếu bạn đặt tên group ở frontend
            'name' => ['required', 'string'], // 👈 cần validate bắt buộc
            'slug' => [
                'required',
                'string',
                Rule::unique('settings', 'slug')->ignore($this->route('setting')),
            ],
            'value' => ['nullable', 'string'],
            'parent_id' => ['nullable', 'exists:settings,id'],
        ];
    }

    /**
     * Custom error messages.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Vui lòng nhập tên của nhóm cài đặt.',
            'slug.required' => 'Vui lòng nhập định danh (slug) cho nhóm cài đặt.',
            'slug.unique' => 'Slug này đã tồn tại. Vui lòng chọn một slug khác.',
            'parent_id.exists' => 'Tab cha không hợp lệ.',
        ];
    }

    /**
     * Custom attribute labels.
     */
    public function attributes(): array
    {
        return [
            'group' => 'Tên nhóm',
            'name' => 'Tên hiển thị',
            'slug' => 'Slug',
            'value' => 'Mô tả',
            'parent_id' => 'Tab cha',
        ];
    }
}
