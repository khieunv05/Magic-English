<?php

namespace App\Http\Controllers;

use App\Models\Post;

use App\Http\Resources\Post\PostCollection;
use App\Http\Resources\Post\PostResource;

class PostsController extends Controller
{
    // Danh sách bài viết
    public function index()
    {
        $posts = Post::with(['category', 'user'])
        ->where('status', Post::PUBLISHED)
        ->orderBy('id', 'DESC')
        ->take(8)
        ->get();

        return PostCollection::collection($posts);
    }

    // Lấy chi tiết bài viết
    public function view(Post $post)
    {
        $data = $post->load(['category', 'user']);

        return $this->apiResponse(
            true,
            'Success',
            new PostResource($data)
        );
    }
}
