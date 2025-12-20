<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

use App\Models\User;

use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\User\UserCollection;
use App\Http\Resources\User\UserResource;

use Modules\Admin\Http\Requests\Admin\CreateAdminRequest;
use Modules\Admin\Http\Requests\Admin\UpdateAdminRequest;

class AdminController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $per_page = $request->per_page ?? 12;
        $page = $request->page ?? 1;

        $data = User::where('is_staff', User::IS_STAFF)
            ->keywords(urldecode($request->keywords))
            ->status($request->status)
            ->date($request->start_date, $request->end_date)
            ->orderBy('id', 'DESC')
            ->paginate($per_page, ['*'], 'page', $page);

        return UserCollection::collection($data);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateAdminRequest $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'is_staff' => User::IS_STAFF,
                'status' => $request->status,
                'image' => $request->image,
                'password' => Hash::make($request->password),
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Admin created successfully', $data);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Admin creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id)
    {
        try {
            $data = User::where('is_staff', User::IS_STAFF)->findOrFail($id);

            return $this->apiResponse(true, 'Admin retrieved successfully', new UserResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Admin not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving admin: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateAdminRequest $request, User $user): JsonResponse
    {
        DB::beginTransaction();

        $user = User::where('is_staff', User::IS_STAFF)->findOrFail($user->id);
        try {
            $user->update([
                'name' => $request->name,
                'role' => $request->role,
                'status' => $request->status,
                'image' => $request->image,
                'password' => $request->password ? Hash::make($request->password) : $user->password,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Admin updated successfully', $user);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Admin update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $data = User::where('is_staff', User::IS_STAFF)->findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Admin deleted successfully');
    }

    /**
     * Show the specified resource.
     */
    public function Me(): JsonResponse
    {
        try {
            $auth = Auth::user();
            $resource = User::with('roles')->where('is_staff', User::IS_STAFF)->findOrFail($auth->id);

            return $this->apiResponse(true, 'Retrieved successfully', new UserResource($resource));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving admin: ' . $exception->getMessage());
        }
    }
}
