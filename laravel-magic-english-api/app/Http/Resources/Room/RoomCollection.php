<?php

namespace App\Http\Resources\Room;

use Illuminate\Support\Carbon;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\Variant\VariantCollection;
use App\Http\Resources\Buildings\BuildingsResource;
use App\Http\Resources\User\UserResource;

class RoomCollection extends JsonResource
{
    protected ?int $user_id;

    public function __construct($resource, $user_id = null)
    {
        parent::__construct($resource);
        $this->user_id = $user_id;
    }

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
            'price' => (int) $this->price,
            'discount' => (int) $this->discount,
            'content' => $this->content,
            'images' => $this->images,
            'status' => $this->status,
            'googlemaps_iframe' => $this->googlemaps_iframe,
            'googlemaps_link' => $this->googlemaps_link,

            // Kiểm tra `is_favorite` tối ưu
            'is_favorite' => $this->checkIfFavorite(),

            // Phí dịch vụ
            'service' => [
                'electricity' => (int) $this->service_electricity,
                'water' => (int) $this->service_water,
                'internet' => (int) $this->service_internet,
                'common' => (int) $this->service_common,
            ],

            // Nội thất (Sử dụng `boolval()` để đảm bảo dữ liệu đúng kiểu boolean)
            'furniture' => [
                'air_conditioning' => boolval($this->has_air_conditioning),
                'heater' => boolval($this->has_heater),
                'kitchen_shelf' => boolval($this->has_kitchen_shelf),
                'bed' => boolval($this->has_bed),
                'table_and_chairs' => boolval($this->has_table_and_chairs),
                'wardrobe' => boolval($this->has_wardrobe),
                'refrigerator' => boolval($this->has_refrigerator),
                'washing_machine' => boolval($this->has_washing_machine),
                'kitchen_utensils' => boolval($this->has_kitchen_utensils),
                'decorative_lights' => boolval($this->has_decorative_lights),
                'decorative_paintings' => boolval($this->has_decorative_paintings),
                'plants' => boolval($this->has_plants),
                'bedding' => boolval($this->has_bedding),
                'mattress' => boolval($this->has_mattress),
                'shoe_rack' => boolval($this->has_shoe_rack),
                'curtains' => boolval($this->has_curtains),
                'ceiling_fan' => boolval($this->has_ceiling_fan),
                'full_length_mirror' => boolval($this->has_full_length_mirror),
                'sofa' => boolval($this->has_sofa),
            ],

            // Tiện nghi
            'amenities' => [
                'private_bathroom' => boolval($this->has_private_bathroom),
                'mezzanine' => boolval($this->has_mezzanine),
                'balcony' => boolval($this->has_balcony),
                'fingerprint_access' => boolval($this->has_fingerprint_access),
                'no_owner_living' => boolval($this->no_owner_living),
                'allows_pets' => boolval($this->allows_pets),
                'flexible_hours' => boolval($this->flexible_hours),
            ],

            // Loại phòng
            'room_type' => $this->room_type,
            'renter_gender' => $this->renter_gender,
            'max_people' => (int) $this->max_people,
            'area' => (int) $this->area,

            // Quan hệ
            'buildings' => new BuildingsResource($this->whenLoaded('buildings')),
            'variants' => VariantCollection::collection($this->whenLoaded('variants')),
            'user' => new UserResource($this->whenLoaded('user')),

            // Format lại `created_at` và `updated_at`
            'created_at' => $this->formatDate($this->created_at),
            'updated_at' => $this->formatDate($this->updated_at),
        ];
    }

    /**
     * Kiểm tra phòng này có phải là yêu thích của user không
     *
     * @return bool
     */
    private function checkIfFavorite(): bool
    {
        if (!$this->relationLoaded('favorites') || !$this->user_id) {
            return false;
        }

        return $this->favorites->contains('user_id', $this->user_id);
    }

    /**
     * Định dạng ngày tháng
     *
     * @param string|null $date
     * @return string|null
     */
    private function formatDate($date): ?string
    {
        return $date ? Carbon::parse($date)->format('d-m-Y H:i:s') : null;
    }
}
