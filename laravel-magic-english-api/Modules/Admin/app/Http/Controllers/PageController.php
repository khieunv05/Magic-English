<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use App\Http\Resources\Page\PageCollection;
use App\Http\Resources\Page\PageResource;

use Modules\Admin\Http\Requests\Page\PageStoreRequest;
use Modules\Admin\Http\Requests\Page\PageUpdateRequest;

use App\Models\Page;

class PageController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if ($request->ids) {
            return $this->action($request->all(), Page::class);
        }

        $per_page = $request->per_page ?? 20;
        $page = $request->page ?? 1;

        $datas = Page::with('user')
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

        return PageCollection::collection($datas);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(PageStoreRequest $request): JsonResponse
    {
        DB::beginTransaction();
        $auth = Auth::user();

        try {
            $data = Page::create([
                'title' => $request->title,
                'slug' => Str::slug($request->title, '-'),
                'user_id' => $auth->id,
                'status' => $request->status,
                'description' => $request->description,
                'body' => $request->body,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Page created successfully', $data);
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, 'Page creation failed: ' . $exception->getMessage());
        }
    }

    /**
     * Show the specified resource.
     */
    public function show($id): JsonResponse
    {
        try {
            // Truy vấn trang đơn theo ID
            $data = Page::with('user')->findOrFail($id);

            return $this->apiResponse(true, 'Page retrieved successfully', new PageResource($data));
        } catch (ModelNotFoundException $exception) {
            return $this->apiResponse(false, 'Page not found');
        } catch (Throwable $exception) {
            return $this->apiResponse(false, 'Error retrieving post: ' . $exception->getMessage());
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(PageUpdateRequest $request, $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $data = Page::findOrFail($id);

            $data->update([
                'title' => $request->title,
                'slug' => Str::slug($request->slug, '-'),
                'body' => $request->body,
                'description' => $request->description,
                'status' => $request->status,
                'user_id' => $request->user_id ?? $data->user_id,
                'meta_title' => $request->meta_title,
                'meta_description' => $request->meta_description,
                'meta_keywords' => $request->meta_keywords
            ]);

            DB::commit();

            return $this->apiResponse(true, 'Page updated successfully', $data);
        } catch (ModelNotFoundException $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Page not found');
        } catch (Throwable $exception) {
            DB::rollBack();
            return $this->apiResponse(false, 'Page update failed: ' . $exception->getMessage());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $data = Page::findOrFail($id);

        $data->delete();

        return $this->apiResponse(true, 'Page deleted successfully');
    }
}
