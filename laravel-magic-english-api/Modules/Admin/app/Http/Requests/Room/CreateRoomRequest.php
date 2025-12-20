<?php

namespace Modules\Admin\Http\Requests\Room;

use Illuminate\Foundation\Http\FormRequest;

class CreateRoomRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'        => 'required|string|max:500',

            'building_id' => 'required|integer',

            'price'       => 'required|numeric',
            'content'     => 'required|string',
            'images'      => 'nullable|array',
            'images.*'    => 'string',
            'room_type'   => 'required|string|in:rooms,whole_house,apartment,mini_apartment,homestay',
            'status'      => 'required|string|in:active,inactive',

            // Phí dịch vụ
            'service.electricity' => 'nullable|numeric|min:0',
            'service.water'       => 'nullable|numeric|min:0',
            'service.internet'    => 'nullable|numeric|min:0',
            'service.common'      => 'nullable|numeric|min:0',

            // Nội thất
            'furniture.air_conditioning'   => 'boolean',
            'furniture.heater'             => 'boolean',
            'furniture.kitchen_shelf'      => 'boolean',
            'furniture.bed'                => 'boolean',
            'furniture.table_and_chairs'   => 'boolean',
            'furniture.wardrobe'           => 'boolean',
            'furniture.refrigerator'       => 'boolean',
            'furniture.washing_machine'    => 'boolean',
            'furniture.kitchen_utensils'   => 'boolean',
            'furniture.decorative_lights'  => 'boolean',
            'furniture.decorative_paintings' => 'boolean',
            'furniture.plants'             => 'boolean',
            'furniture.bedding'            => 'boolean',
            'furniture.mattress'           => 'boolean',
            'furniture.shoe_rack'          => 'boolean',
            'furniture.curtains'           => 'boolean',
            'furniture.ceiling_fan'        => 'boolean',
            'furniture.full_length_mirror' => 'boolean',
            'furniture.sofa'               => 'boolean',

            // Tiện nghi
            'amenities.private_bathroom' => 'boolean',
            'amenities.mezzanine'        => 'boolean',
            'amenities.balcony'          => 'boolean',
            'amenities.fingerprint_access' => 'boolean',
            'amenities.no_owner_living'  => 'boolean',
            'amenities.allows_pets'      => 'boolean',
            'amenities.flexible_hours'   => 'boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required'        => 'Tên phòng là bắt buộc.',
            'price.required'       => 'Giá phòng là bắt buộc.',
            'content.required'     => 'Nội dung mô tả phòng là bắt buộc.',

            // Toà nhà
            'building_id.required' => 'Vui lòng chọn toà nhà.',

            'room_type.in' => 'Loại phòng không hợp lệ. Chỉ chấp nhận: rooms, whole_house, apartment, mini_apartment, homestay.',
            'status.in'    => 'Trạng thái không hợp lệ. Chỉ chấp nhận: active hoặc inactive.',

            // Phí dịch vụ
            'service.electricity.numeric' => 'Phí điện phải là số.',
            'service.water.numeric'       => 'Phí nước phải là số.',
            'service.internet.numeric'    => 'Phí internet phải là số.',
            'service.common.numeric'      => 'Phí dịch vụ chung phải là số.',
        ];
    }
}
