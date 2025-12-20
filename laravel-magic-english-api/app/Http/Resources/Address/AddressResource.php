<?php

namespace App\Http\Resources\Address;

use Illuminate\Http\Resources\Json\JsonResource;

class AddressResource extends JsonResource
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
            'province' => $this->province,
            'district' => $this->district,
            'ward' => $this->ward,
            'street' => $this->street,
            'postal_code' => $this->postal_code,

            'image' => $this->whenLoaded('addressImage')
        ];
    }
}
