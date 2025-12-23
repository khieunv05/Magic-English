<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Room\RoomCollection;
use App\Http\Resources\Room\RoomResource;

use Modules\Admin\Http\Requests\Room\CreateRoomRequest;
use Modules\Admin\Http\Requests\Room\UpdateRoomRequest;

use App\Models\Room;

class RoomController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), Room::class);
        }

        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = Room::with('user', 'buildings', 'variants')
            ->keywords(urldecode($request->keywords))
            ->status($request->status)
            ->date($request->start_date, $request->end_date)
            ->orderBy('id', 'DESC')
            ->paginate(
                $per_page,
                ['*'],
                'page',
                $page
            );

        return RoomCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateRoomRequest $request): JsonResponse
    {
        DB::beginTransaction();
        $user = Auth::user();

        try {
            $room = Room::create([
                'user_id' => $user->id,
                'name' => $request->name,
                'slug' => Str::slug($request->name),
                'price' => $request->price,
                'discount' => $request->discount,
                'content' => $request->content,
                'status' => $request->status,
                'images' => json_encode($request->images),
                'building_id' => $request->building_id,
                'googlemaps_iframe' => $request->googlemaps_iframe,
                'googlemaps_link' => $request->googlemaps_link,

                // Phí dịch vụ (Lấy từ object service)
                'service_electricity' => $request->service['electricity'],
                'service_water' => $request->service['water'],
                'service_internet' => $request->service['internet'],
                'service_common' => $request->service['common'],

                // Nội thất (Lấy từ object furniture)
                'has_air_conditioning' => $request->furniture['air_conditioning'],
                'has_heater' => $request->furniture['heater'],
                'has_kitchen_shelf' => $request->furniture['kitchen_shelf'],
                'has_bed' => $request->furniture['bed'],
                'has_table_and_chairs' => $request->furniture['table_and_chairs'],
                'has_wardrobe' => $request->furniture['wardrobe'],
                'has_refrigerator' => $request->furniture['refrigerator'],
                'has_washing_machine' => $request->furniture['washing_machine'],
                'has_kitchen_utensils' => $request->furniture['kitchen_utensils'],
                'has_decorative_lights' => $request->furniture['decorative_lights'],
                'has_decorative_paintings' => $request->furniture['decorative_paintings'],
                'has_plants' => $request->furniture['plants'],
                'has_bedding' => $request->furniture['bedding'],
                'has_mattress' => $request->furniture['mattress'],
                'has_shoe_rack' => $request->furniture['shoe_rack'],
                'has_curtains' => $request->furniture['curtains'],
                'has_ceiling_fan' => $request->furniture['ceiling_fan'],
                'has_full_length_mirror' => $request->furniture['full_length_mirror'],
                'has_sofa' => $request->furniture['sofa'],

                // Tiện nghi (Lấy từ object amenities)
                'has_private_bathroom' => $request->amenities['private_bathroom'],
                'has_mezzanine' => $request->amenities['mezzanine'],
                'has_balcony' => $request->amenities['balcony'],
                'has_fingerprint_access' => $request->amenities['fingerprint_access'],
                'no_owner_living' => $request->amenities['no_owner_living'],
                'allows_pets' => $request->amenities['allows_pets'],
                'flexible_hours' => $request->amenities['flexible_hours'],

                // Loại phòng
                'room_type' => $request->room_type,
                'renter_gender' => $request->renter_gender,
                'area' => $request->area,
                'max_people' => $request->max_people,
            ]);

            // Tạo các variants nếu có
            if ($request->has('variants')) {
                foreach ($request->variants as $variantData) {
                    $room->variants()->create([
                        'code' => $variantData['code'],
                        'floor' => $variantData['floor'],
                        'area' => $variantData['area'],
                        'max_people' => $variantData['max_people'],
                        'price' => $variantData['price'],
                        'deposit' => $variantData['deposit'],
                        'images' => json_encode($variantData['images']),
                    ]);
                }
            }

            DB::commit();

            return $this->apiResponse(true, 'Room created successfully', $room);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Room creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            $data = Room::with('user', 'buildings', 'variants')->findOrFail($id); // Tìm phòng theo ID

            return $this->apiResponse(true, 'Room retrieved successfully', new RoomResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Room not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving room: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateRoomRequest $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $room = Room::findOrFail($id);
            $images = $room->images;
            $user = Auth::user();

            if ($request->images && $request->images !== $room->images) {
                $images = json_encode($request->images);
            }

            $room->update([
                'user_id' => $user->id,
                'name' => $request->name,
                'slug' => $request->slug,
                'price' => $request->price,
                'discount' => $request->discount,
                'content' => $request->content,
                'images' => $images,
                'status' => $request->status,
                'building_id' => $request->building_id,
                'googlemaps_iframe' => $request->googlemaps_iframe,
                'googlemaps_link' => $request->googlemaps_link,

                // Phí dịch vụ (Lấy từ object service)
                'service_electricity' => $request->service['electricity'],
                'service_water' => $request->service['water'],
                'service_internet' => $request->service['internet'],
                'service_common' => $request->service['common'],

                // Nội thất (Lấy từ object furniture)
                'has_air_conditioning' => $request->furniture['air_conditioning'],
                'has_heater' => $request->furniture['heater'],
                'has_kitchen_shelf' => $request->furniture['kitchen_shelf'],
                'has_bed' => $request->furniture['bed'],
                'has_table_and_chairs' => $request->furniture['table_and_chairs'],
                'has_wardrobe' => $request->furniture['wardrobe'],
                'has_refrigerator' => $request->furniture['refrigerator'],
                'has_washing_machine' => $request->furniture['washing_machine'],
                'has_kitchen_utensils' => $request->furniture['kitchen_utensils'],
                'has_decorative_lights' => $request->furniture['decorative_lights'],
                'has_decorative_paintings' => $request->furniture['decorative_paintings'],
                'has_plants' => $request->furniture['plants'],
                'has_bedding' => $request->furniture['bedding'],
                'has_mattress' => $request->furniture['mattress'],
                'has_shoe_rack' => $request->furniture['shoe_rack'],
                'has_curtains' => $request->furniture['curtains'],
                'has_ceiling_fan' => $request->furniture['ceiling_fan'],
                'has_full_length_mirror' => $request->furniture['full_length_mirror'],
                'has_sofa' => $request->furniture['sofa'],

                // Tiện nghi (Lấy từ object amenities)
                'has_private_bathroom' => $request->amenities['private_bathroom'],
                'has_mezzanine' => $request->amenities['mezzanine'],
                'has_balcony' => $request->amenities['balcony'],
                'has_fingerprint_access' => $request->amenities['fingerprint_access'],
                'no_owner_living' => $request->amenities['no_owner_living'],
                'allows_pets' => $request->amenities['allows_pets'],
                'flexible_hours' => $request->amenities['flexible_hours'],

                // Loại phòng
                'room_type' => $request->room_type,
                'renter_gender' => $request->renter_gender,
                'area' => $request->area,
                'max_people' => $request->max_people,
            ]);

            // Cập nhật hoặc thêm mới `variants`
            if ($request->has('variants')) {
                // Lấy danh sách ID của variants được gửi lên
                $variantIds = array_column($request->variants, 'id');

                // Xóa các variants không có trong danh sách ID
                $room->variants()->whereNotIn('id', $variantIds)->delete();

                // Cập nhật hoặc thêm mới `variants`
                foreach ($request->variants as $variantData) {
                    $variant = $room->variants()->where('id', $variantData['id'])->first();

                    if ($variant) {
                        // Cập nhật variant hiện có
                        $variant->update([
                            'code' => $variantData['code'],
                            'floor' => $variantData['floor'],
                            'area' => $variantData['area'],
                            'max_people' => $variantData['max_people'],
                            'price' => $variantData['price'],
                            'deposit' => $variantData['deposit'],
                            'images' => json_encode($variantData['images']),
                        ]);
                    } else {
                        // Tạo variant mới
                        $room->variants()->create([
                            'code' => $variantData['code'],
                            'floor' => $variantData['floor'],
                            'area' => $variantData['area'],
                            'max_people' => $variantData['max_people'],
                            'price' => $variantData['price'],
                            'deposit' => $variantData['deposit'],
                            'images' => json_encode($variantData['images']),
                        ]);
                    }
                }
            }

            DB::commit();

            return $this->apiResponse(true, 'Room updated successfully', $room);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Room not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Room update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Room::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Room deleted successfully');
    }
}
