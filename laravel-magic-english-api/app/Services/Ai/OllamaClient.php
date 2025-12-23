<?php

namespace App\Services\Ai;

use Illuminate\Support\Facades\Http;

class OllamaClient
{
  protected string $baseUrl;
  protected string $model;

  public function __construct(?string $baseUrl = null, ?string $model = null)
  {
    $this->baseUrl = rtrim((string) ($baseUrl ?: config('ai.ollama_base_url', 'http://localhost:11434/v1')), '/');
    $this->model = (string) ($model ?: config('ai.ollama_model', 'qwen2.5:3b'));
  }

  public function analyze(string $text, array $params = []): array
  {
    $scaleMax = (int) ($params['scale_max'] ?? 10);
    $style = (string) ($params['style'] ?? 'concise');
    $language = (string) ($params['language'] ?? 'vi');

    $instruction = $this->buildInstruction($scaleMax, $style, $language);

    $payload = [
      'model' => $this->model,
      'messages' => [
        ['role' => 'system', 'content' => $instruction],
        ['role' => 'user', 'content' => "USER_TEXT:\n" . $text],
      ],
      'temperature' => 0.2,
      'stream' => false,
    ];

    $url = $this->baseUrl . '/chat/completions';
    $response = Http::timeout(30)->acceptJson()->post($url, $payload);

    if (!$response->successful()) {
      return [
        'status' => false,
        'message' => 'Ollama API error: ' . $response->status(),
        'result' => ['response' => $response->json()],
      ];
    }

    $data = $response->json();
    $content = $data['choices'][0]['message']['content'] ?? '';

    // Try parse JSON strictly
    $parsed = $this->safeJsonDecode($content);
    if ($parsed === null) {
      $clean = preg_replace('/^```json|```$/m', '', (string) $content);
      $parsed = $this->safeJsonDecode((string) $clean);
    }

    if (!is_array($parsed)) {
      return [
        'status' => false,
        'message' => 'Unable to parse AI response.',
        'result' => ['raw' => $content],
      ];
    }

    return [
      'status' => true,
      'message' => 'Success',
      'result' => $parsed,
    ];
  }

  protected function buildInstruction(int $scaleMax, string $style, string $language): string
  {
    return <<<PROMPT
You are an English writing evaluator. Analyze the user's English sentence(s) for grammar, spelling, and style.
Return STRICT JSON only with this exact shape (no extra text):
{
  "score": <integer 0-{$scaleMax}>,
  "issues": [
    {"type": "grammar"|"spelling"|"style", "message": "short in {$language}", "original": "fragment", "suggestion": "fix"}
  ],
  "suggestions": ["Rewrite suggestion 1", "Rewrite suggestion 2"],
  "overall_feedback": "One-paragraph feedback in {$language}"
}
Guidelines:
- Consider clarity, correctness, and naturalness. Keep style {$style}.
- If text is perfect, still include a high score and minor suggestions.
- Never include code fences or explanations; output valid JSON only.
PROMPT;
  }

  protected function safeJsonDecode(string $json): ?array
  {
    $decoded = json_decode($json, true);
    return json_last_error() === JSON_ERROR_NONE ? $decoded : null;
  }
}
