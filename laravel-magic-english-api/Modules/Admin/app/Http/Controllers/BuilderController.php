<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

use App\Http\Resources\Builder\BuilderCollection;
use App\Http\Resources\Builder\BuilderResource;

use App\Models\Builder;
use App\Models\BuilderBlock;
use Modules\Admin\Http\Requests\Builder\BuilderStoreRequest;
use Modules\Admin\Http\Requests\Builder\BuilderUpdateRequest;
use Modules\Admin\Http\Requests\Builder\BuilderReorderRequest;

class BuilderController extends \App\Http\Controllers\Controller
{
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), Builder::class);
        }

        $perPage = (int) $request->input('per_page', 20);
        $page    = (int) $request->input('page', 1);

        $builders = Builder::query()
            ->withCount(['blocks as items_count'])
            ->keywords(urldecode($request->input('keywords')))
            ->orderBy('id', 'DESC')
            ->paginate($perPage, ['*'], 'page', $page);

        return BuilderCollection::collection($builders);
    }

    public function store(BuilderStoreRequest $request): JsonResponse
    {
        $data = $request->validated();

        $data['slug']   = $data['slug'] ?? (Str::slug($data['name']) . '-' . Str::random(6));
        $data['status'] = $data['status'] ?? 'draft';

        $builder = Builder::create($data);

        return $this->apiResponse(true, 'Builder created successfully', new BuilderResource($builder));
    }

    public function show(Builder $builder): JsonResponse
    {
        $builder->load('blocks');
        return $this->apiResponse(true, 'Builder retrieved successfully', new BuilderResource($builder));
    }

    public function update(BuilderUpdateRequest $request, Builder $builder): JsonResponse
    {
        $data = $request->validated();

        if (isset($data['name']) && empty($data['slug'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        $builder->update($data);

        return $this->apiResponse(true, 'Builder updated successfully', new BuilderResource($builder->fresh('blocks')));
    }

    public function destroy(Builder $builder): JsonResponse
    {
        $builder->delete();
        return $this->apiResponse(true, 'Builder deleted successfully');
    }

    public function updateOrder(BuilderReorderRequest $request, Builder $builder): JsonResponse
    {
        $payload = $request->validated();

        DB::beginTransaction();
        try {
            $this->persistBlockOrder($payload['tree'], null, $builder->id);
            DB::commit();
            return $this->apiResponse(true, 'Block order updated successfully');
        } catch (Throwable $e) {
            DB::rollBack();
            return $this->apiResponse(false, 'Failed to update order: ' . $e->getMessage());
        }
    }

    private function persistBlockOrder(array $nodes, ?int $parentId, int $builderId): void
    {
        foreach ($nodes as $index => $node) {
            if (!isset($node['id'])) {
                continue;
            }

            BuilderBlock::query()
                ->where('builder_id', $builderId)
                ->where('id', $node['id'])
                ->update([
                    'parent_id'  => $parentId,
                    'sort_order' => $index,
                ]);

            if (!empty($node['children']) && is_array($node['children'])) {
                $this->persistBlockOrder($node['children'], $node['id'], $builderId);
            }
        }
    }
}
