<?php

namespace Modules\Admin\Http\Requests\Builder;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Models\Builder;

class BuilderUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        /** @var Builder|null $builder */
        $builder = $this->route('builder'); // route-model binding

        return [
            'name'         => ['sometimes', 'string', 'max:255'],
            'slug'         => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('builders', 'slug')->ignore($builder?->id),
            ],
            'description'  => ['nullable', 'string'],
            'status'       => ['nullable', 'in:draft,published'],
            'thumbnail'    => ['nullable', 'string'],
            'options'      => ['nullable', 'array'],
            'published_at' => ['nullable', 'date'],
        ];
    }
}
