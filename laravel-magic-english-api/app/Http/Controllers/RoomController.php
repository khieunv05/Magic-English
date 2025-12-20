<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Auth;

use App\Http\Resources\Room\RoomCollection;
use App\Http\Resources\Room\RoomResource;

use App\Models\Room;

class RoomController extends Controller
{
    // Danh sách phòng
    public function index(Request $request): AnonymousResourceCollection
    {
        $per_page = $request->input('per_page', 12);
        $page = $request->input('page', 1);
        $keywords = urldecode($request->input('keywords', null));
        $sortKey = $request->input('sort_key', 'id');
        $sortValue = $request->input('per_value', 'DESC');

        // Nhận dữ liệu `areaSize` (min & max)
        $minArea = $request->input('minArea');
        $maxArea = $request->input('maxArea');
        // Nhận dữ liệu `priceRange` (min & max)
        $minPrice = $request->input('minPrice');
        $maxPrice = $request->input('maxPrice');
        // Nhận dữ liệu `area` (quận/huyện)
        $area = $request->input('area');
        // Nhận dữ liệu `room_types`
        $roomType = $request->input('room_type');

        // Các bộ lọc dịch vụ và tiện nghi từ request
        $filters = [
            'service_electricity' => $request->input('service_electricity'),
            'service_water' => $request->input('service_water'),
            'service_internet' => $request->input('service_internet'),
            'service_common' => $request->input('service_common'),

            'has_air_conditioning' => $request->input('has_air_conditioning'),
            'has_heater' => $request->input('has_heater'),
            'has_kitchen_shelf' => $request->input('has_kitchen_shelf'),
            'has_bed' => $request->input('has_bed'),
            'has_table_and_chairs' => $request->input('has_table_and_chairs'),
            'has_wardrobe' => $request->input('has_wardrobe'),
            'has_private_bathroom' => $request->input('has_private_bathroom'),
            'has_fingerprint_access' => $request->input('has_fingerprint_access'),
            'no_owner_living' => $request->input('no_owner_living'),
        ];

        // Áp dụng tìm kiếm từ khóa và bộ lọc dịch vụ/tiện nghi
        $rooms = Room::with('user', 'buildings', 'variants')
                        ->keywords($keywords)
                        ->filterAttributes($filters)
                        ->orderBy($sortKey, $sortValue)
                        ->area($minArea, $maxArea)
                        ->byDistrict($area)
                        ->roomType($roomType)
                        ->price($minPrice, $maxPrice)
                        ->paginate($per_page, ['*'], 'page', $page);

        return RoomCollection::collection($rooms);
    }

    // Xem phòng
    public function view(Room $room): RoomResource
    {
        $room->load('user', 'buildings', 'variants', 'favorites');
        $user_id = Auth::guard('sanctum')->id();

        return new RoomResource($room, $user_id);
    }

    // Phòng liên quan
    public function related(Room $room): JsonResponse
    {
        // Lấy các phòng liên quan dựa trên tỉnh/thành phố từ địa chỉ và loại trừ phòng hiện tại
        $relatedRooms = Room::whereHas('buildings', function ($query) use ($room) {
                                    $query->where('province', $room->buildings->province);
                                })
                                ->where('id', '!=', $room->id)
                                ->with('user', 'buildings', 'variants')
                                ->take(8)
                                ->get();

        return $this->apiResponse(true, 'Successfully', $relatedRooms);
    }
}
