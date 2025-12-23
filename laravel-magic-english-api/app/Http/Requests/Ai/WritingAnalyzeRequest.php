<?php

namespace App\Http\Requests\Ai;

use Illuminate\Foundation\Http\FormRequest;

class WritingAnalyzeRequest extends FormRequest
{
  public function authorize(): bool
  {
    return true;
  }

  public function rules(): array
  {
    return [
      'text' => ['required', 'string', 'min:1'],
      'scale_max' => ['nullable', 'integer', 'min:5', 'max:100'],
      'style' => ['nullable', 'string'],
      'language' => ['nullable', 'string'],
    ];
  }

  public function messages(): array
  {
    return [
      'text.required' => 'Vui lòng nhập câu hoặc đoạn văn tiếng Anh.',
      'text.string' => 'Nội dung phải là chuỗi.',
      'text.min' => 'Nội dung không được rỗng.',
      'scale_max.integer' => 'Thang điểm phải là số.',
      'scale_max.min' => 'Thang điểm tối thiểu là 5.',
      'scale_max.max' => 'Thang điểm tối đa là 100.',
    ];
  }
}
