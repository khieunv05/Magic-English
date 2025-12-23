<?php

namespace App\Http\Resources\Notebook;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

use App\Http\Resources\User\UserResource;

class NotebookResource extends JsonResource
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
            'name' => $this->name,
            'description' => $this->description,
            'is_favorite' => (bool) $this->is_favorite,
            'user' => new UserResource($this->whenLoaded('user')),

            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
