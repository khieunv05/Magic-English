<?php

namespace App\Http\Controllers;

use App\Models\Vocabulary;
use App\Models\Notebook;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\QueryException;

use App\Http\Requests\Vocabulary\StoreVocabularyRequest;
use App\Http\Requests\Vocabulary\UpdateVocabularyRequest;
use App\Http\Resources\Vocabulary\VocabularyCollection;
use App\Http\Resources\Vocabulary\VocabularyResource;
use App\Services\Tracking\ActivityLogger;
use App\Services\Vocabulary\VocabularyEnrichService;

class VocabularyController extends Controller
{
  public function __construct(private readonly VocabularyEnrichService $enricher)
  {
  }

  // List vocabularies in a notebook
  public function index(Notebook $notebook, Request $request): JsonResponse
  {
    if ($notebook->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $query = Vocabulary::query()
      ->with(['user', 'notebook'])
      ->where('notebook_id', $notebook->id);

    if ($request->filled('word')) {
      $query->where('word', 'like', '%' . $request->string('word') . '%');
    }
    if ($request->filled('q')) {
      $q = $request->string('q');
      $query->where(function ($qBuilder) use ($q) {
        $qBuilder->where('word', 'like', "%{$q}%")
          ->orWhere('meaning', 'like', "%{$q}%");
      });
    }
    if ($request->filled('part_of_speech')) {
      $query->where('part_of_speech', $request->string('part_of_speech'));
    }
    if ($request->filled('cefr_level')) {
      $query->where('cefr_level', $request->string('cefr_level'));
    }

    $items = $query->orderByDesc('id')->paginate($request->integer('per_page', 10));

    return $this->apiResponse(true, 'Lấy danh sách từ vựng thành công', [
      'items' => VocabularyCollection::collection($items->items()),
      'pagination' => [
        'total' => $items->total(),
        'per_page' => $items->perPage(),
        'current_page' => $items->currentPage(),
        'last_page' => $items->lastPage(),
      ],
    ]);
  }

  // Create a vocabulary inside a notebook
  public function store(Notebook $notebook, StoreVocabularyRequest $request): JsonResponse
  {
    if ($notebook->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Không phải sổ tay của bạn', []);
    }

    $data = $request->validated();
    $data['user_id'] = Auth::id();
    $data['notebook_id'] = $notebook->id;

    try {
      $vocabulary = Vocabulary::create($data);
      $vocabulary->load(['user', 'notebook']);
      app(ActivityLogger::class)->log(Auth::id(), 'vocabulary_added', [
        'vocabulary_id' => $vocabulary->id,
        'notebook_id' => $vocabulary->notebook_id,
        'part_of_speech' => $vocabulary->part_of_speech ?? null,
        'cefr_level' => $vocabulary->cefr_level ?? null,
      ]);
      return $this->apiResponse(true, 'Tạo từ vựng thành công', new VocabularyResource($vocabulary));
    } catch (QueryException $e) {
      if ((int) $e->getCode() === 23000) {
        return $this->apiResponse(false, 'Từ này đã tồn tại trong sổ.', []);
      }
      return $this->apiResponse(false, 'Lỗi cơ sở dữ liệu: ' . $e->getMessage(), []);
    }
  }

  // Show a vocabulary
  public function show(Vocabulary $vocabulary): JsonResponse
  {
    if ($vocabulary->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $vocabulary->load(['user', 'notebook']);
    return $this->apiResponse(true, 'Lấy thông tin từ vựng thành công', new VocabularyResource($vocabulary));
  }

  // Update a vocabulary
  public function update(Vocabulary $vocabulary, UpdateVocabularyRequest $request): JsonResponse
  {
    if ($vocabulary->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $data = $request->validated();
    $vocabulary->update($data);
    $vocabulary->load(['user', 'notebook']);

    return $this->apiResponse(true, 'Chỉnh sửa từ vựng thành công', new VocabularyResource($vocabulary));
  }

  // Delete a vocabulary
  public function destroy(Vocabulary $vocabulary): JsonResponse
  {
    if ($vocabulary->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }

    $vocabulary->delete();
    return $this->apiResponse(true, 'Xóa từ vựng thành công', []);
  }

  // Enrich a vocabulary by word using Gemini
  public function enrich(Request $request): JsonResponse
  {
    $request->validate([
      'word' => ['required', 'string', 'max:100'],
    ], [
      'word.required' => 'Vui lòng nhập từ vựng.',
      'word.string' => 'Từ vựng không hợp lệ.',
      'word.max' => 'Độ dài tối đa 100 ký tự.',
    ]);

    $word = (string) $request->input('word');
    $ai = $this->enricher->enrich($word);

    if (!($ai['status'] ?? false)) {
      return $this->apiResponse(false, $ai['message'] ?? 'AI error', $ai['result'] ?? []);
    }

    // Normalize minimal keys in case model returns variants
    $payload = $ai['result'];
    $result = [
      'word' => $payload['word'] ?? $word,
      'ipa' => $payload['ipa'] ?? null,
      'meaning_vi' => $payload['meaning_vi'] ?? ($payload['meaning'] ?? null),
      'part_of_speech' => $payload['part_of_speech'] ?? null,
      'examples' => $payload['examples'] ?? [],
      'cefr' => $payload['cefr'] ?? null,
    ];

    return $this->apiResponse(true, 'Tra cứu từ vựng bằng AI thành công', $result);
  }
}
