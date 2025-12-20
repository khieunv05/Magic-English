<?php

namespace App\Http\Resources\Builder;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

class BuilderResource extends JsonResource
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
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'status' => $this->status,
            'thumbnail' => $this->thumbnail,
            'options' => $this->options,
            'published_at' => $this->published_at ? Carbon::parse($this->published_at)->format('d-m-Y H:i:s') : null,
            'blocks' => BuilderBlockResource::collection($this->whenLoaded('blocks')),
            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
