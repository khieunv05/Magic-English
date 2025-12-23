<?php

namespace App\Http\Requests\Grammar;

use Illuminate\Foundation\Http\FormRequest;

class RescoreGrammarCheckRequest extends FormRequest
{
  public function authorize(): bool
  {
    return auth()->check();
  }

  public function rules(): array
  {
    return [
      'text' => ['required', 'string', 'min:3', 'max:10000'],
    ];
  }

  public function messages(): array
  {
    return [
      'text.required' => 'Vui lòng nhập đoạn văn để chấm lại.',
      'text.min' => 'Đoạn văn quá ngắn.',
      'text.max' => 'Đoạn văn quá dài (tối đa 10000 kí tự).',
    ];
  }

  public function attributes(): array
  {
    return [
      'text' => 'đoạn văn',
    ];
  }
}
