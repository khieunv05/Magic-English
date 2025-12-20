<?php

namespace App\Http\Resources\Buildings;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

class BuildingsResource extends JsonResource
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
            'province' => $this->province,
            'district' => $this->district,
            'ward' => $this->ward,
            'street' => $this->street,
            'postal_code' => $this->postal_code,
            'image' => $this->image,

            'facade' => $this->facade,
            'reception' => $this->reception,
            'lobby' => $this->lobby,
            'room' => $this->room,
            'washroom' => $this->washroom,

            'rooms' => $this->whenLoaded('rooms'),

            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
