<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Post\PostCollection;
use App\Http\Resources\Post\PostResource;

use Modules\Admin\Http\Requests\Post\PostStoreRequest;
use Modules\Admin\Http\Requests\Post\PostUpdateRequest;

use App\Models\Post;

class PostController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), Post::class);
        }

        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = Post::with('user')
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

        return PostCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(PostStoreRequest $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = Post::create([
                'user_id' => Auth::user()->id,
                'status' => $request->status,
                'category_id' => $request->category_id,
                'title' => $request->title,
                'slug' => Str::slug($request->title, '-'),
                'content' => $request->content,
                'image' => $request->image,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords,
                'published_at' => $request->published_at,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Post created successfully', $data);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Post creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            // Truy vấn bài viết theo ID
            $data = Post::with('user')->findOrFail($id);

            return $this->apiResponse(true, 'Post retrieved successfully', new PostResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Post not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving post: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(PostUpdateRequest $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = Post::findOrFail($id);

            $image = $data->image;
            if ($request->image && $request->image !== $data->image) {
                $image = $request->image;
            }

            $data->update([
                'title' => $request->title,
                'slug' => $request->slug,
                'content' => $request->content,
                'status' => $request->status,
                'category_id' => $request->category_id,
                'user_id' => $request->user_id ?? $data->user_id,
                'image' => $image,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords,
                'published_at' => $request->published_at,
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Post updated successfully', $data);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Post not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Post update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Post::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Post deleted successfully');
    }
}
