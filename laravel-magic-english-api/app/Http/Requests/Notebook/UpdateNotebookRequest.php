<?php

namespace App\Http\Requests\Notebook;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class UpdateNotebookRequest extends FormRequest
{
  public function authorize(): bool
  {
    return true;
  }

  public function rules(): array
  {
    $notebook = $this->route('notebook');
    $userId = Auth::id() ?? optional($notebook)->user_id;

    return [
      'name' => [
        'sometimes',
        'string',
        'max:255',
        Rule::unique('notebooks')
          ->ignore(optional($notebook)->id)
          ->where(fn($q) => $q->where('user_id', $userId)),
      ],
      'description' => ['nullable', 'string'],
      'is_favorite' => ['nullable', 'boolean'],
    ];
  }

  public function messages(): array
  {
    return [
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
      'name' => 'tên sổ',
      'description' => 'mô tả',
      'is_favorite' => 'yêu thích',
    ];
  }
}
