<?php

namespace Modules\User\Http\Controllers;

use App\Http\Resources\User\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Carbon;
use Modules\User\Http\Requests\User\UpdateUserRequest;

class UserController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return view('user::index');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('user::create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
    }

    /**
     * Show the specified resource.
     */
    public function show(Request $request): JsonResponse
    {
        $user_id = Auth::user()->id;
        $user = User::where('id', $user_id)
            ->first();

        return $this->apiResponse(
            true,
            'Success',
            new UserResource($user),
        );
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        return view('user::edit');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateUserRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $data = $request->validated();

        // Map fields that exist on users table
        $updates = [];
        if (isset($data['name']))
            $updates['name'] = $data['name'];
        if (!empty($data['email']))
            $updates['email'] = strtolower(trim($data['email']));
        if (!empty($data['phone']))
            $updates['phone'] = $data['phone'];
        if (!empty($data['gender']))
            $updates['gender'] = $data['gender'];
        if (!empty($data['heard_from']))
            $updates['heard_from'] = $data['heard_from'];

        // Birthday -> date_of_birth
        if (!empty($data['birthday'])) {
            try {
                $updates['date_of_birth'] = Carbon::parse($data['birthday'])->toDateString();
            } catch (\Throwable $e) {
                // Ignore parse error; validation should have prevented this
            }
        }

        // Image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('avatars', 'public');
            $updates['image'] = 'storage/' . $path;
        }

        // Password change (optional)
        if (!empty($data['password'])) {
            $updates['password'] = \Illuminate\Support\Facades\Hash::make($data['password']);
        }

        if (!empty($updates)) {
            $user->fill($updates)->save();
        }

        return $this->apiResponse(true, 'Cập nhật thông tin người dùng thành công', new UserResource($user));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
    }
}
