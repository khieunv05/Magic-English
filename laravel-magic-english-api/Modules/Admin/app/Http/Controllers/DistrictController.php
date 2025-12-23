<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\AddressImage\AddressImageCollection;
use App\Http\Resources\AddressImage\AddressImageResource;

use App\Models\AddressImage;

class DistrictController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), AddressImage::class);
        }

        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = AddressImage::keywords(urldecode($request->keywords))
            ->orderBy('id', 'DESC')
            ->paginate(
                $per_page,
                ['*'],
                'page',
                $page
            );

        return AddressImageCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = AddressImage::create([
                'province' => $request->province,
                'district' => $request->district,
                'image' => $request->image,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'AddressImage created successfully', $data);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'AddressImage creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            $data = AddressImage::findOrFail($id);

            return $this->apiResponse(true, 'AddressImage retrieved successfully', new AddressImageResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'AddressImage not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving AddressImage: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = AddressImage::findOrFail($id);

            $image = $data->image;
            if ($request->image && $request->image !== $data->image) {
                $image = $request->image;
            }

            $data->update([
                'province' => $request->province,
                'district' => $request->district,
                'image' => $image,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'AddressImage updated successfully', $data);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'AddressImage not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'AddressImage update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = AddressImage::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'AddressImage deleted successfully');
    }
}
