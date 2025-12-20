<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class AddressController extends Controller
{
    /**
     * GET /api/address/provinces
     * Lấy danh sách tỉnh/thành phố
     */
    public function provinces()
    {
        $data = DB::select('SELECT code, name FROM provinces ORDER BY name');
        return $this->apiResponse(true, 'Danh sách tỉnh/thành', $data);
    }

    /**
     * GET /api/address/districts/{provinceCode}
     * Lấy danh sách quận/huyện theo tỉnh
     */
    public function districts(string $provinceCode)
    {
        $data = DB::select(
            'SELECT code, name FROM districts WHERE province_code = ? ORDER BY name',
            [$provinceCode]
        );

        return $this->apiResponse(true, 'Danh sách quận/huyện', $data);
    }

    /**
     * GET /api/address/wards/{districtCode}
     * Lấy danh sách phường/xã theo quận/huyện
     */
    public function wards(string $districtCode)
    {
        $data = DB::select(
            'SELECT code, name FROM wards WHERE district_code = ? ORDER BY name',
            [$districtCode]
        );

        return $this->apiResponse(true, 'Danh sách phường/xã', $data);
    }
}
