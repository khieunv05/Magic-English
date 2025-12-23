<?php

namespace Modules\Admin\Http\Requests\Room;

use Illuminate\Foundation\Http\FormRequest;

class UpdateRoomRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Logic kiểm tra quyền người dùng
        return true; // Hoặc thêm điều kiện kiểm tra quyền
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:500',
            'slug' => 'required|string|max:500',

            'building_id' => 'required|integer',

            'price' => 'required|numeric',
            'content' => 'required|string',
            'images' => 'nullable|array',
            'images.*' => 'string',
            'room_type' => 'required|string|in:rooms,whole_house,apartment,mini_apartment,homestay',
            'status' => 'required|string|in:active,inactive',

            // Phí dịch vụ (nằm trong object service)
            'service.electricity' => 'nullable|numeric|min:0',
            'service.water' => 'nullable|numeric|min:0',
            'service.internet' => 'nullable|numeric|min:0',
            'service.common' => 'nullable|numeric|min:0',

            // Nội thất (furniture)
            'furniture.air_conditioning' => 'boolean',
            'furniture.heater' => 'boolean',
            'furniture.kitchen_shelf' => 'boolean',
            'furniture.bed' => 'boolean',
            'furniture.table_and_chairs' => 'boolean',
            'furniture.wardrobe' => 'boolean',
            'furniture.refrigerator' => 'boolean',
            'furniture.washing_machine' => 'boolean',
            'furniture.kitchen_utensils' => 'boolean',
            'furniture.decorative_lights' => 'boolean',
            'furniture.decorative_paintings' => 'boolean',
            'furniture.plants' => 'boolean',
            'furniture.bedding' => 'boolean',
            'furniture.mattress' => 'boolean',
            'furniture.shoe_rack' => 'boolean',
            'furniture.curtains' => 'boolean',
            'furniture.ceiling_fan' => 'boolean',
            'furniture.full_length_mirror' => 'boolean',
            'furniture.sofa' => 'boolean',

            // Tiện nghi (amenities)
            'amenities.private_bathroom' => 'boolean',
            'amenities.mezzanine' => 'boolean',
            'amenities.balcony' => 'boolean',
            'amenities.fingerprint_access' => 'boolean',
            'amenities.no_owner_living' => 'boolean',
            'amenities.allows_pets' => 'boolean',
            'amenities.flexible_hours' => 'boolean',
        ];
    }

    /**
     * Custom messages for validation errors.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Tên phòng là bắt buộc.',
            'price.required' => 'Giá phòng là bắt buộc.',
            'content.required' => 'Nội dung mô tả phòng là bắt buộc.',
            'user_id.exists' => 'ID người dùng không hợp lệ.',
            'room_type.in' => 'Loại phòng không hợp lệ. Chỉ chấp nhận: Phòng trọ, Nguyên căn, Chung cư, Chung cư mini, Homestay.',
            'status.in' => 'Trạng thái không hợp lệ. Chỉ chấp nhận: Active hoặc Inactive.',

            'building_id.required' => 'Vui lòng chọn toà nhà.',

            // Địa chỉ
            'address.street.required' => 'Địa chỉ đường là bắt buộc.',
            'address.province.required' => 'Tỉnh/thành phố là bắt buộc.',

            // Phí dịch vụ
            'service.electricity.numeric' => 'Phí điện phải là số.',
            'service.water.numeric' => 'Phí nước phải là số.',
            'service.internet.numeric' => 'Phí internet phải là số.',
            'service.common.numeric' => 'Phí dịch vụ chung phải là số.',

            // Nội thất
            'furniture.air_conditioning.boolean' => 'Giá trị điều hòa phải là kiểu boolean.',
        ];
    }
}
