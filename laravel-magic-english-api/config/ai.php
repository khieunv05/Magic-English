<?php

return [
  'gemini_api_key' => env('GEMINI_API_KEY'),
  // Default to requested preview model on v1beta
  'gemini_model' => env('GEMINI_MODEL', 'models/gemini-3-flash-preview'),
  'gemini_base_url' => env('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
  'ollama_base_url' => env('OLLAMA_BASE_URL', 'http://localhost:11434/v1'),
  'ollama_model' => env('OLLAMA_MODEL', 'qwen2.5:3b'),
];
