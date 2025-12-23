<?php

namespace App\Services\Grammar;

use App\Services\Ai\GeminiClient;

class GrammarAnalyzeService
{
    public function __construct(private readonly GeminiClient $gemini)
    {
    }

    /**
     * Analyze text and normalize structure to schema fields.
     * Returns: [score:int, errors:array, suggestions:array]
     */
    public function analyze(string $text): array
    {
        $response = $this->gemini->analyze($text);

        // Expected structure from GeminiClient: ['status'=>..., 'result'=>array|mixed]
        $score = 0;
        $errors = [];
        $suggestions = [];

        if (is_array($response)) {
            $payload = $response['result'] ?? $response;

            // Accept a variety of possible keys and normalize
            if (isset($payload['score'])) {
                $score = (int) $payload['score'];
            } elseif (isset($payload['rating'])) {
                $score = (int) $payload['rating'];
            }

            $errors = $this->normalizeList($payload['errors'] ?? ($payload['issues'] ?? []));
            $suggestions = $this->normalizeList($payload['suggestions'] ?? []);
        }

        // Clamp score 0..100
        $score = max(0, min(100, $score));

        return [
            'score' => $score,
            'errors' => $errors,
            'suggestions' => $suggestions,
        ];
    }

    private function normalizeList($value): array
    {
        if (is_string($value)) {
            // Split by newline or semicolon if a block string slips through
            $parts = preg_split('/\r?\n|;\s*/', $value) ?: [];
            return array_values(array_filter(array_map('trim', $parts)));
        }
        if (!is_array($value)) {
            return [];
        }
        // If array of objects, try to extract 'message' or 'text' fields
        $out = [];
        foreach ($value as $item) {
            if (is_string($item)) {
                $out[] = trim($item);
            } elseif (is_array($item)) {
                $out[] = trim((string)($item['message'] ?? $item['text'] ?? json_encode($item)));
            }
        }
        return array_values(array_filter($out));
    }
}
