<?php

namespace App\Http\Resources\AddressImage;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

use App\Http\Resources\Buildings\BuildingsCollection;

class AddressImageCollection extends JsonResource
{
    /**
     * Transform the resource collection into an array.
     *
     * @return array<int|string, mixed>
     */
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'province' => $this->province,
            'district' => $this->district,
            'image' => $this->image,

            'buildings' => BuildingsCollection::collection($this->whenLoaded('buildings')),
            'building_count' => $this->whenLoaded('buildings', fn() => $this->buildings->count()),

            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
