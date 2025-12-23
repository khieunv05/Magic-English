<?php

namespace Modules\Admin\Http\Requests\Builder;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Arr;
use Illuminate\Validation\Rule;
use App\Models\Builder;
use Illuminate\Support\Facades\DB;

class BuilderReorderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        // Kiểm tra level đầu và 1 cấp con (đủ dùng cho nhiều case).
        // Với tree lồng quá sâu, ta sẽ kiểm tra sâu bằng after() bên dưới.
        /** @var Builder|null $builder */
        $builder = $this->route('builder');

        return [
            'tree'                  => ['required', 'array'],
            'tree.*.id'             => [
                'required',
                'integer',
                Rule::exists('builder_blocks', 'id')->where('builder_id', $builder?->id),
            ],
            'tree.*.children'       => ['nullable', 'array'],
            'tree.*.children.*.id'  => [
                'required_with:tree.*.children',
                'integer',
                Rule::exists('builder_blocks', 'id')->where('builder_id', $builder?->id),
            ],
        ];
    }

    /**
     * Nếu cần validate “mọi cấp độ” trong tree:
     * - Duyệt toàn bộ tree, gom tất cả id, đối chiếu 1 lần với DB và builder_id.
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($v) {
            $payload = $this->input('tree', []);
            $allIds = $this->collectIdsRecursively($payload);
            if (empty($allIds)) {
                return;
            }

            /** @var Builder|null $builder */
            $builder = $this->route('builder');

            $count = DB::table('builder_blocks')
                ->where('builder_id', $builder?->id)
                ->whereIn('id', $allIds)
                ->count();

            if ($count !== count($allIds)) {
                $v->errors()->add('tree', 'Có block không thuộc builder hiện tại hoặc không tồn tại.');
            }
        });
    }

    private function collectIdsRecursively(array $nodes): array
    {
        $ids = [];
        foreach ($nodes as $node) {
            if (isset($node['id'])) {
                $ids[] = (int) $node['id'];
            }
            $children = Arr::get($node, 'children', []);
            if (is_array($children) && !empty($children)) {
                $ids = array_merge($ids, $this->collectIdsRecursively($children));
            }
        }
        return $ids;
    }
}
