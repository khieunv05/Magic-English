<?php

namespace App\Http\Requests\Vocabulary;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreVocabularyRequest extends FormRequest
{
  public function authorize(): bool
  {
    return true;
  }

  protected function prepareForValidation(): void
  {
    // notebook_id comes from route parameter
    $this->merge([
      'notebook_id' => optional($this->route('notebook'))->id,
    ]);
  }

  public function rules(): array
  {
    return [
      'word' => [
        'required',
        'string',
        'max:255',
        Rule::unique('vocabularies')->where(fn($q) => $q->where('notebook_id', $this->input('notebook_id'))),
      ],
      'meaning' => ['required', 'string'],
      'part_of_speech' => ['required', 'string'],
      'ipa' => ['nullable', 'string'],
      'example' => ['nullable', 'string'],
      'cefr_level' => ['required', 'string', 'in:A1,A2,B1,B2,C1,C2'],
    ];
  }

  public function messages(): array
  {
    return [
      'word.required' => 'Từ vựng là bắt buộc.',
      'word.string' => 'Từ vựng phải là chuỗi.',
      'word.max' => 'Từ vựng không được vượt quá 255 ký tự.',
      'word.unique' => 'Từ này đã tồn tại trong sổ.',

      'meaning.required' => 'Nghĩa của từ là bắt buộc.',
      'part_of_speech.required' => 'Loại từ là bắt buộc.',
      'ipa.string' => 'Phiên âm IPA phải là chuỗi.',
      'example.string' => 'Ví dụ phải là chuỗi.',
      'cefr_level.required' => 'CEFR là bắt buộc.',
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
