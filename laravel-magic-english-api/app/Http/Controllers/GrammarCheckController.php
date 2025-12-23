<?php

namespace App\Http\Controllers;

use App\Http\Requests\Grammar\StoreGrammarCheckRequest;
use App\Http\Requests\Grammar\RescoreGrammarCheckRequest;
use App\Http\Resources\Grammar\GrammarCheckResource;
use App\Models\GrammarCheck;
use App\Services\Grammar\GrammarAnalyzeService;
use App\Services\Tracking\ActivityLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class GrammarCheckController extends Controller
{
  public function __construct(private readonly GrammarAnalyzeService $analyzer)
  {
  }

  public function index(Request $request)
  {
    $userId = Auth::id();

    $query = GrammarCheck::query()->where('user_id', $userId)->latest('id');

    $pageSize = (int) ($request->integer('page_size') ?: 15);
    $pageSize = max(1, min(100, $pageSize));

    $paginator = $query->paginate($pageSize);

    return GrammarCheckResource::collection($paginator);
  }

  public function store(StoreGrammarCheckRequest $request)
  {
    $userId = Auth::id();
    $text = $request->string('text')->toString();

    $result = $this->analyzer->analyze($text);

    $record = GrammarCheck::create([
      'user_id' => $userId,
      'original_text' => $text,
      'score' => (int) ($result['score'] ?? 0),
      'errors' => $result['errors'] ?? [],
      'suggestions' => $result['suggestions'] ?? [],
    ]);

    // Log activity: grammar scored
    app(ActivityLogger::class)->log($userId, 'grammar_scored', [
      'grammar_check_id' => $record->id,
      'score' => $record->score,
    ]);

    return (new GrammarCheckResource($record))
      ->response()
      ->setStatusCode(200);
  }

  public function rescore(RescoreGrammarCheckRequest $request, GrammarCheck $grammarCheck): JsonResponse
  {
    $this->authorizeOwnership($grammarCheck);

    $text = $request->string('text')->toString();

    $result = $this->analyzer->analyze($text);

    $grammarCheck->update([
      'original_text' => $text,
      'score' => (int) ($result['score'] ?? 0),
      'errors' => $result['errors'] ?? [],
      'suggestions' => $result['suggestions'] ?? [],
    ]);

    // Log activity: grammar rescored
    app(ActivityLogger::class)->log(Auth::id(), 'grammar_scored', [
      'grammar_check_id' => $grammarCheck->id,
      'score' => $grammarCheck->score,
    ]);

    return (new GrammarCheckResource($grammarCheck->fresh()))
      ->response()
      ->setStatusCode(200);
  }

  public function destroy(GrammarCheck $grammarCheck): JsonResponse
  {
    $this->authorizeOwnership($grammarCheck);

    $grammarCheck->delete();

    return response()->json([
      'status' => true,
      'message' => 'Đã xóa đoạn văn.',
    ], 200);
  }

  public function show(GrammarCheck $grammarCheck)
  {
    $this->authorizeOwnership($grammarCheck);

    return new GrammarCheckResource($grammarCheck);
  }

  private function authorizeOwnership(GrammarCheck $grammarCheck): void
  {
    if ($grammarCheck->user_id !== Auth::id()) {
      abort(403, 'Bạn không có quyền với tài nguyên này.');
    }
  }
}
