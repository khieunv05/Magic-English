<?php

namespace App\Http\Requests\Vocabulary;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateVocabularyRequest extends FormRequest
{
  public function authorize(): bool
  {
    return true;
  }

  public function rules(): array
  {
    $vocabulary = $this->route('vocabulary');
    $notebookId = optional($vocabulary)->notebook_id;

    return [
      'word' => [
        'sometimes',
        'string',
        'max:255',
        Rule::unique('vocabularies')
          ->ignore(optional($vocabulary)->id)
          ->where(fn($q) => $q->where('notebook_id', $notebookId)),
      ],
      'meaning' => ['sometimes', 'string'],
      'part_of_speech' => ['sometimes', 'string'],
      'ipa' => ['nullable', 'string'],
      'example' => ['nullable', 'string'],
      'cefr_level' => ['sometimes', 'string', 'in:A1,A2,B1,B2,C1,C2'],
    ];
  }

  public function messages(): array
  {
    return [
      'word.string' => 'Từ vựng phải là chuỗi.',
      'word.max' => 'Từ vựng không được vượt quá 255 ký tự.',
      'word.unique' => 'Từ này đã tồn tại trong sổ.',

      'meaning.string' => 'Nghĩa của từ phải là chuỗi.',
      'part_of_speech.string' => 'Loại từ phải là chuỗi.',
      'ipa.string' => 'Phiên âm IPA phải là chuỗi.',
      'example.string' => 'Ví dụ phải là chuỗi.',
      'cefr_level.in' => 'CEFR phải thuộc A1, A2, B1, B2, C1 hoặc C2.',
    ];
  }

  public function attributes(): array
  {
    return [
      'word' => 'từ vựng',
      'meaning' => 'nghĩa',
      'part_of_speech' => 'loại từ',
      'ipa' => 'phiên âm IPA',
      'example' => 'ví dụ',
      'cefr_level' => 'trình độ CEFR',
    ];
  }
}
