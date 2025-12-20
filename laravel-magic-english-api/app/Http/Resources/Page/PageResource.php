<?php

namespace App\Http\Resources\Page;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

use App\Http\Resources\User\UserResource;

class PageResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'description' => $this->description,
            'body' => $this->body,
            'image' => $this->image,
            'status' => $this->status,
            'meta_title' => $this->meta_title,
            'meta_description' => $this->meta_description,
            'meta_keywords' => $this->meta_keywords,

            'user' => new UserResource($this->whenLoaded('user')),

            'published_at' => $this->published_at ?? Carbon::parse($this->published_at)->format('d-m-Y H:i:s'),
            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
