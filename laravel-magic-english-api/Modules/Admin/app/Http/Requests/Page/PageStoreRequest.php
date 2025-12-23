<?php

namespace Modules\Admin\Http\Requests\Page;

use Illuminate\Foundation\Http\FormRequest;

class PageStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'image' => 'nullable|image|max:2048',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:255',
            'meta_keywords' => 'nullable|string|max:255',
            'status' => 'required|in:draft,published,archived',
            'published_at' => 'nullable|date',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Tiêu đề bài viết là bắt buộc.',
            'title.max' => 'Tiêu đề bài viết không được vượt quá 255 ký tự.',
            'image.image' => 'Tệp tải lên phải là hình ảnh.',
            'image.max' => 'Hình ảnh không được vượt quá 2MB.',
            'status.required' => 'Trạng thái bài viết là bắt buộc.',
            'status.in' => 'Trạng thái không hợp lệ.',
            'published_at.date' => 'Ngày xuất bản phải là định dạng ngày hợp lệ.',
        ];
    }
}
