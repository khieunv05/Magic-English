<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Buildings\BuildingsCollection;
use App\Http\Resources\Buildings\BuildingsResource;

use App\Models\Buildings;

class BuildingsController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = Buildings::with('rooms')
            ->keywords(urldecode($request->keywords))
            ->date($request->start_date, $request->end_date)
            ->orderBy('id', 'DESC')
            ->paginate(
                $per_page,
                ['*'],
                'page',
                $page
            );

        return BuildingsCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $buildings = Buildings::create([
                'name' => $request->name,
                'province' => $request->province,
                'district' => $request->district,
                'ward' => $request->ward,
                'street' => $request->street,
                'postal_code' => $request->postal_code,
                'image' => $request->image,
                'facade' => $request->facade,
                'reception' => $request->reception,
                'lobby' => $request->lobby,
                'room' => $request->room,
                'washroom' => $request->washroom,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Buildings created successfully', $buildings);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Buildings creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            $data = Buildings::with('rooms')->findOrFail($id);

            return $this->apiResponse(true, 'Buildings retrieved successfully', new BuildingsResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Buildings not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving room: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $buildings = Buildings::findOrFail($id);

            $buildings->update([
                'name' => $request->name,
                'province' => $request->province,
                'district' => $request->district,
                'ward' => $request->ward,
                'street' => $request->street,
                'postal_code' => $request->postal_code,
                'image' => $request->image,
                'facade' => $request->facade,
                'reception' => $request->reception,
                'lobby' => $request->lobby,
                'room' => $request->room,
                'washroom' => $request->washroom,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Buildings updated successfully', $buildings);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Buildings not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Buildings update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Buildings::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Buildings deleted successfully');
    }
}
