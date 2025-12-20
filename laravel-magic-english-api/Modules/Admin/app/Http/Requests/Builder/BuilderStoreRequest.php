<?php

namespace Modules\Admin\Http\Requests\Builder;

use Illuminate\Foundation\Http\FormRequest;

class BuilderStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'         => ['required', 'string', 'max:255'],
            'slug'         => ['nullable', 'string', 'max:255', 'unique:builders,slug'],
            'description'  => ['nullable', 'string'],
            'status'       => ['nullable', 'in:draft,published'],
            'thumbnail'    => ['nullable', 'string'],
            'options'      => ['nullable', 'array'],
            'published_at' => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Tên là bắt buộc.',
            'slug.unique'   => 'Slug đã tồn tại.',
        ];
    }
}
