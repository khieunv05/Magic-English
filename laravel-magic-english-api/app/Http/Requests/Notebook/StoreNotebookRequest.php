<?php

namespace App\Http\Requests\Notebook;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class StoreNotebookRequest extends FormRequest
{
  public function authorize(): bool
  {
    return true;
  }

  protected function prepareForValidation(): void
  {
    $this->merge([
      'user_id' => $this->input('user_id', Auth::id()),
    ]);
  }

  public function rules(): array
  {
    return [
      'user_id' => ['required', 'integer', 'exists:users,id'],
      'name' => [
        'required',
        'string',
        'max:255',
        Rule::unique('notebooks')
          ->where(fn($q) => $q->where('user_id', $this->input('user_id'))),
      ],
      'description' => ['nullable', 'string'],
      'is_favorite' => ['nullable', 'boolean'],
    ];
  }

  public function messages(): array
  {
    return [
      'user_id.required' => 'Thiếu người dùng xác thực.',
      'user_id.integer' => 'ID người dùng phải là số.',
      'user_id.exists' => 'Người dùng không tồn tại.',

      'name.required' => 'Tên sổ là bắt buộc.',
      'name.string' => 'Tên sổ phải là chuỗi.',
      'name.max' => 'Tên sổ không được vượt quá 255 ký tự.',
      'name.unique' => 'Tên sổ đã tồn tại trong tài khoản của bạn.',

      'description.string' => 'Mô tả phải là chuỗi.',
      'is_favorite.boolean' => 'Giá trị yêu thích phải là true/false.',
    ];
  }

  public function attributes(): array
  {
    return [
      'user_id' => 'người dùng',
      'name' => 'tên sổ',
      'description' => 'mô tả',
      'is_favorite' => 'yêu thích',
    ];
  }
}
