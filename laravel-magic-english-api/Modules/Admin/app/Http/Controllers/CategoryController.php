<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;

use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Category\CategoryCollection;
use App\Http\Resources\Category\CategoryResource;

use Modules\Admin\Http\Requests\Category\CategoryStoreRequest;
use Modules\Admin\Http\Requests\Category\CategoryUpdateRequest;

use App\Models\Category;
use Illuminate\Support\Facades\Auth;

class CategoryController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), Category::class);
        }

        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $data = Category::with('user')
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

        return CategoryCollection::collection($data);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CategoryStoreRequest $request): JsonResponse
    {
        DB::beginTransaction();
        $auth = Auth::user();

        try {
            $data = Category::create([
                'name' => $request->name,
                'slug' => Str::slug($request->name),
                'description' => $request->description,
                'content' => $request->content,
                'image' => $request->image,
                'status' => $request->status,
                'user_id' => $auth->id,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Resource created successfully', $data);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Resource creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            $data = Category::findOrFail($id);

            return $this->apiResponse(true, 'Resource retrieved successfully', new CategoryResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Resource not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving category: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(CategoryUpdateRequest $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = Category::findOrFail($id);
            $auth = Auth::user();

            $data->update([
                'name' => $request->name,
                'slug' => $request->slug,
                'description' => $request->description,
                'content' => $request->content,
                'image' => $request->image,
                'status' => $request->status,
                'user_id' => $auth->id,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Resource updated successfully', $data);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Resource not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Resource update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Category::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Resource deleted successfully');
    }
}
