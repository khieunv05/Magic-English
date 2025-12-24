<?php

namespace App\Services\Vocabulary;

use App\Services\Ai\GeminiClient;

class VocabularyEnrichService
{
  public function __construct(private readonly GeminiClient $gemini)
  {
  }

  /**
   * Enrich vocabulary info via Gemini.
   * Input: single English word or phrase.
   * Output keys: word, ipa, meaning_vi, part_of_speech, examples[], cefr
   */
  public function enrich(string $word): array
  {
    $instruction = <<<PROMPT
You are an English dictionary assistant.
Given an English WORD, return STRICT JSON only (no extra text) with the schema:
{
  "word": "<the word as given>",
  "ipa": "<IPA transcription (prefer British, no slashes)>",
  "meaning_vi": "<short Vietnamese meaning>",
  "part_of_speech": "noun|verb|adjective|adverb|preposition|conjunction|pronoun|determiner|interjection",
  "examples": ["Simple example sentence 1", "Simple example sentence 2"],
  "cefr": "A1|A2|B1|B2|C1|C2"
}
Guidelines:
- If multiple parts of speech exist, pick the most common one.
- Keep IPA concise, phonemic style (prefer BrE).
- Provide short, clear Vietnamese meaning.
- Provide 2 short, common example sentences.
- Output valid JSON only, no code fences.
PROMPT;

    $result = $this->gemini->generateCustom($instruction, ["WORD:\n" . trim($word)]);
    return $result;
  }
}
