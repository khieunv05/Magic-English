<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Booking\BookingCollection;
use App\Http\Resources\Booking\BookingResource;

use App\Models\Booking;

class BookingController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = Booking::with('room', 'user')
            ->keywords(urldecode($request->keywords))
            ->date($request->start_date, $request->end_date)
            ->orderBy('id', 'DESC')
            ->paginate(
                $per_page,
                ['*'],
                'page',
                $page
            );

        return BookingCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $booking = Booking::create([
                'description' => $request->description,
                'time' => Carbon::now(),
                'user_id' => $request->user_id,
                'room_id' => $request->room_id,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Booking created successfully', $booking);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Booking creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            $data = Booking::with('user', 'room')->findOrFail($id);

            return $this->apiResponse(true, 'Booking retrieved successfully', new BookingResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Booking not found');
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
            $booking = Booking::findOrFail($id);

            $booking->update([
                'description' => $request->description,
                'time' => Carbon::now(),
                'user_id' => $request->user_id,
                'room_id' => $request->room_id,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Booking updated successfully', $booking);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Booking not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Booking update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Booking::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Booking deleted successfully');
    }
}
