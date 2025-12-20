<?php

namespace App\Http\Resources\Variant;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

class VariantResource extends JsonResource
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
            'code' => $this->code,
            'floor' => $this->floor,
            'area' => $this->area,
            'max_people' => $this->max_people,
            'price' => (int) $this->price,
            'deposit' => (int) $this->deposit,
            'images' => $this->images,

            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
