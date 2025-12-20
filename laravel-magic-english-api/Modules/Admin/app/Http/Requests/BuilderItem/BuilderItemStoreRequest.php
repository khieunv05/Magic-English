<?php

namespace Modules\Admin\Http\Requests\BuilderItem;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Models\Builder;

class BuilderItemStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        /** @var Builder|null $builder */
        $builder = $this->route('builder');

        return [
            'parent_id' => [
                'nullable',
                Rule::exists('builder_blocks', 'id')->where('builder_id', $builder?->id),
            ],
            'title'      => ['nullable', 'string', 'max:255'],
            'slug'       => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('builder_blocks', 'slug')
                    ->where(fn($q) => $q->where('builder_id', $builder?->id)),
            ],
            'block_type' => ['required', 'string', 'max:100'],
            'content'    => ['nullable', 'array'],
            'media'      => ['nullable', 'array'],
            'settings'   => ['nullable', 'array'],
            'status'     => ['nullable', Rule::in(['draft', 'published'])],
            'target'     => ['nullable', Rule::in(['_self', '_blank'])],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
