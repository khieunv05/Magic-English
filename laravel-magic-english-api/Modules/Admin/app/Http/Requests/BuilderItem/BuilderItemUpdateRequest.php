<?php

namespace Modules\Admin\Http\Requests\BuilderItem;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Models\BuilderBlock;

class BuilderItemUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        /** @var BuilderBlock|null $builderBlock */
        $builderBlock = $this->route('builderBlock');
        $builderId = $builderBlock?->builder_id;

        return [
            'parent_id' => [
                'nullable',
                Rule::exists('builder_blocks', 'id')->where('builder_id', $builderId),
            ],
            'title'      => ['nullable', 'string', 'max:255'],
            'slug'       => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('builder_blocks', 'slug')
                    ->where(fn($q) => $q->where('builder_id', $builderId))
                    ->ignore($builderBlock?->id),
            ],
            'block_type' => ['sometimes', 'string', 'max:100'],
            'content'    => ['nullable', 'array'],
            'media'      => ['nullable', 'array'],
            'settings'   => ['nullable', 'array'],
            'status'     => ['nullable', Rule::in(['draft', 'published'])],
            'target'     => ['nullable', Rule::in(['_self', '_blank'])],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($v) {
            /** @var BuilderBlock|null $current */
            $current = $this->route('builderBlock');
            $parentId = $this->input('parent_id');

            if ($current && $parentId && (int)$parentId === (int)$current->id) {
                $v->errors()->add('parent_id', 'Một block không thể là parent của chính nó.');
            }
        });
    }
}
