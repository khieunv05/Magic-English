<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;

use App\Http\Resources\AddressImage\AddressImageCollection;
use App\Http\Resources\AddressImage\AddressImageResource;

use App\Models\AddressImage;

class DistrictController extends Controller
{
    // Lấy danh sách các tỉnh/thành phố (province) mà có phòng (Room) liên kết
    public function index(Request $request)
    {
        $data = Cache::remember("address_district", Carbon::now()->addDays(10), function () {
            return AddressImage::with('buildings')->get();
        });

        return AddressImageCollection::collection($data);
    }

    // Lấy danh sách các Room của Address hiện tại
    public function view(AddressImage $district)
    {
        $resource = AddressImage::with("buildings")
                                ->where('id', $district->id)
                                ->first();

        return new AddressImageResource($resource);
    }
}
