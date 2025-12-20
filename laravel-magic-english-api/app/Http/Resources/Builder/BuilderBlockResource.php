<?php

namespace App\Http\Resources\Builder;

use Illuminate\Http\Resources\Json\JsonResource;

class BuilderBlockResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<int|string, mixed>
     */
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'builder_id' => $this->builder_id,
            'parent_id' => $this->parent_id,
            'title' => $this->title,
            'slug' => $this->slug,
            'block_type' => $this->block_type,
            'content' => $this->content,
            'media' => $this->media,
            'settings' => $this->settings,
            'status' => $this->status,
            'target' => $this->target,
            'sort_order' => $this->sort_order,
            'children' => BuilderBlockResource::collection($this->whenLoaded('childrenRecursive')),
            'created_at' => optional($this->created_at)->toDateTimeString(),
            'updated_at' => optional($this->updated_at)->toDateTimeString(),
        ];
    }
}
