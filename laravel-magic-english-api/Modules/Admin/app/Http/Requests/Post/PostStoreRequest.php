<?php

namespace Modules\Admin\Http\Requests\Post;

use Illuminate\Foundation\Http\FormRequest;

class PostStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'image' => 'nullable|max:4048',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:255',
            'meta_keywords' => 'nullable|string|max:255',
            'status' => 'required|in:draft,published,archived',
            'category_id' => 'nullable|exists:categories,id',
            'published_at' => 'nullable|date',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Tiêu đề bài viết là bắt buộc.',
            'title.max' => 'Tiêu đề bài viết không được vượt quá 255 ký tự.',
            'content.required' => 'Nội dung bài viết là bắt buộc.',
            'image.max' => 'Hình ảnh không được vượt quá 4MB.',
            'status.required' => 'Trạng thái bài viết là bắt buộc.',
            'status.in' => 'Trạng thái không hợp lệ.',
            'category_id.exists' => 'Danh mục không tồn tại.',
            'published_at.date' => 'Ngày xuất bản phải là định dạng ngày hợp lệ.',
        ];
    }
}
