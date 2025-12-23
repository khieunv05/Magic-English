<?php

namespace Modules\Admin\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

use App\Http\Resources\Builder\BuilderBlockResource;

use App\Models\Builder;
use App\Models\BuilderBlock;

use Modules\Admin\Http\Requests\BuilderItem\BuilderItemStoreRequest;
use Modules\Admin\Http\Requests\BuilderItem\BuilderItemUpdateRequest;

class BuilderItemController extends \App\Http\Controllers\Controller
{
    public function index(Builder $builder): JsonResponse
    {
        $builder->load('blocks');

        return $this->apiResponse(
            true,
            'Builder blocks fetched successfully',
            BuilderBlockResource::collection($builder->blocks)
        );
    }

    public function store(BuilderItemStoreRequest $request, Builder $builder): JsonResponse
    {
        $data = $request->validated();

        $block = BuilderBlock::create([
            ...$data,
            'builder_id' => $builder->id,
            'sort_order' => (int) (BuilderBlock::where('builder_id', $builder->id)->max('sort_order') ?? -1) + 1,
        ]);

        $block->load('childrenRecursive');

        return $this->apiResponse(true, 'Builder block created successfully', new BuilderBlockResource($block));
    }

    public function show(BuilderBlock $builderBlock): JsonResponse
    {
        $builderBlock->load('childrenRecursive');

        return $this->apiResponse(true, 'Builder block retrieved successfully', new BuilderBlockResource($builderBlock));
    }

    public function update(BuilderItemUpdateRequest $request, BuilderBlock $builderBlock): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($builderBlock, $data) {
            $builderBlock->update($data);
        });

        return $this->apiResponse(
            true,
            'Builder block updated successfully',
            new BuilderBlockResource($builderBlock->fresh('childrenRecursive'))
        );
    }

    public function destroy(BuilderBlock $builderBlock): JsonResponse
    {
        $builderBlock->delete();

        return $this->apiResponse(true, 'Builder block deleted successfully');
    }
}
