<?php

namespace App\Services\Ai;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class GeminiClient
{
  protected string $apiKey;
  protected string $baseUrl;
  protected string $model;

  public function __construct(?string $apiKey = null, ?string $model = null)
  {
    $this->apiKey = $apiKey ?: (string) config('ai.gemini_api_key');
    $this->model = $model ?: (string) config('ai.gemini_model', 'models/gemini-3-flash-preview');
    $this->baseUrl = rtrim((string) config('ai.gemini_base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');
  }

  public function analyze(string $text, array $params = []): array
  {
    if (empty($this->apiKey)) {
      return [
        'status' => false,
        'message' => 'Missing GEMINI_API_KEY configuration.',
        'result' => [],
      ];
    }

    $scaleMax = (int) ($params['scale_max'] ?? 10);
    $style = (string) ($params['style'] ?? 'concise');
    $language = (string) ($params['language'] ?? 'en');

    $systemInstruction = $this->buildInstruction($scaleMax, $style, $language);

    $payload = [
      'contents' => [
        [
          'role' => 'user',
          'parts' => [
            ['text' => $systemInstruction],
            ['text' => "USER_TEXT:\n" . $text],
          ],
        ],
      ],
    ];

    $url = $this->baseUrl . '/' . trim($this->model, '/') . ':generateContent';

    $response = Http::timeout(20)
      ->withHeaders([
        'x-goog-api-key' => $this->apiKey,
        'Content-Type' => 'application/json',
      ])
      ->acceptJson()
      ->post($url, $payload);

    if (!$response->successful()) {
      return [
        'status' => false,
        'message' => 'Gemini API error: ' . $response->status(),
        'result' => [
          'response' => $response->json(),
        ],
      ];
    }

    $data = $response->json();
    $textOut = $this->extractText($data);

    // Try to parse JSON from the model's response
    $parsed = $this->safeJsonDecode($textOut);
    if ($parsed === null) {
      // Attempt to trim code fences if present
      $clean = preg_replace('/^```json|```$/m', '', $textOut);
      $parsed = $this->safeJsonDecode((string) $clean);
    }

    if (!is_array($parsed)) {
      return [
        'status' => false,
        'message' => 'Unable to parse AI response.',
        'result' => [
          'raw' => $textOut,
        ],
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
You are an English writing evaluator. Analyze the given English sentence(s) for grammar, spelling, and style.
Return STRICT JSON only (no extra text, no explanations), with this shape:
{
  "score": <integer 0-{$scaleMax}>,
  "issues": [
    {
      "type": "grammar" | "spelling" | "style",
      "message": "short explanation in {$language}",
      "original": "the original fragment",
      "suggestion": "a suggested fix"
    }
  ],
  "suggestions": ["Rewrite suggestion 1", "Rewrite suggestion 2"],
  "overall_feedback": "One-paragraph feedback in {$language}"
}
Guidelines:
- Consider clarity, correctness, and naturalness. Keep style {$style}.
- If text is perfect, still include a high score and possibly minor suggestions.
- Never include code fences. Output valid JSON only.
PROMPT;
  }

  protected function extractText(array $response): string
  {
    $candidates = $response['candidates'] ?? [];
    foreach ($candidates as $cand) {
      $parts = $cand['content']['parts'] ?? [];
      foreach ($parts as $p) {
        if (isset($p['text']) && is_string($p['text'])) {
          return $p['text'];
        }
      }
    }
    return '';
  }

  protected function safeJsonDecode(string $json): ?array
  {
    $decoded = json_decode($json, true);
    return json_last_error() === JSON_ERROR_NONE ? $decoded : null;
  }

  /**
   * Generic generator with custom instruction and parts.
   * $partsTexts: array of strings appended after instruction as separate parts.
   * Returns ['status'=>bool,'message'=>string,'result'=>array|mixed]
   */
  public function generateCustom(string $instruction, array $partsTexts): array
  {
    if (empty($this->apiKey)) {
      return [
        'status' => false,
        'message' => 'Missing GEMINI_API_KEY configuration.',
        'result' => [],
      ];
    }

    $parts = [['text' => $instruction]];
    foreach ($partsTexts as $t) {
      $parts[] = ['text' => (string) $t];
    }

    $payload = [
      'contents' => [
        [
          'role' => 'user',
          'parts' => $parts,
        ],
      ],
    ];

    $url = $this->baseUrl . '/' . trim($this->model, '/') . ':generateContent';

    $response = Http::timeout(20)
      ->withHeaders([
        'x-goog-api-key' => $this->apiKey,
        'Content-Type' => 'application/json',
      ])
      ->acceptJson()
      ->post($url, $payload);

    if (!$response->successful()) {
      return [
        'status' => false,
        'message' => 'Gemini API error: ' . $response->status(),
        'result' => [
          'response' => $response->json(),
        ],
      ];
    }

    $data = $response->json();
    $textOut = $this->extractText($data);
    $parsed = $this->safeJsonDecode($textOut);
    if ($parsed === null) {
      $clean = preg_replace('/^```json|```$/m', '', $textOut);
      $parsed = $this->safeJsonDecode((string) $clean);
    }

    if (!is_array($parsed)) {
      return [
        'status' => false,
        'message' => 'Unable to parse AI response.',
        'result' => [
          'raw' => $textOut,
        ],
      ];
    }

    return [
      'status' => true,
      'message' => 'Success',
      'result' => $parsed,
    ];
  }
}
