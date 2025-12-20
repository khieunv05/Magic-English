<?php

namespace App\Http\Controllers;

use App\Http\Resources\Buildings\BuildingsCollection;
use App\Http\Resources\Buildings\BuildingsResource;

use App\Models\Buildings;

class BuildingsController extends Controller
{
    // Danh sách tòa nhà
    public function index()
    {
        $buildings = Buildings::orderBy('id', 'DESC')->get();

        return BuildingsCollection::collection($buildings);
    }

    // Lấy danh sách các Room của Buildings hiện tại
    public function view(Buildings $building)
    {
        $buildingWithRelations = $building->load('rooms');

        return $this->apiResponse(
            true,
            'Success',
            new BuildingsResource($buildingWithRelations)
        );
    }
}
