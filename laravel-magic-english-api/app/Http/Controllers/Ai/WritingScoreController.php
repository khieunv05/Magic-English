<?php

namespace App\Http\Controllers\Ai;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ai\WritingAnalyzeRequest;
use App\Services\Ai\GeminiClient;
use App\Services\Ai\OllamaClient;
use Illuminate\Support\Facades\Log;

class WritingScoreController extends Controller
{
  public function analyze(WritingAnalyzeRequest $request)
  {
    $client = new GeminiClient();
    $payload = $request->validated();

    $result = $client->analyze($payload['text'], [
      'scale_max' => $payload['scale_max'] ?? 10,
      'style' => $payload['style'] ?? 'concise',
      'language' => $payload['language'] ?? 'vi',
    ]);

    if (!$result['status']) {
      Log::warning('AI analyze failed', ['error' => $result]);
      return $this->apiResponse(false, $result['message'] ?? 'AI error', $result['result'] ?? []);
    }

    return $this->apiResponse(true, 'Success', $result['result']);
  }

  public function analyzeOllama(WritingAnalyzeRequest $request)
  {
    $client = new OllamaClient();
    $payload = $request->validated();

    $result = $client->analyze($payload['text'], [
      'scale_max' => $payload['scale_max'] ?? 10,
      'style' => $payload['style'] ?? 'concise',
      'language' => $payload['language'] ?? 'vi',
    ]);

    if (!$result['status']) {
      Log::warning('Ollama analyze failed', ['error' => $result]);
      return $this->apiResponse(false, $result['message'] ?? 'AI error', $result['result'] ?? []);
    }

    return $this->apiResponse(true, 'Success', $result['result']);
  }
}
