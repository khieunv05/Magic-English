import 'dart:convert';

import 'package:magic_english_project/api_service/apiservice.dart';
import 'package:magic_english_project/core/config/api_config.dart';
import 'package:magic_english_project/project/dto/vocabulary.dart';

class VocabApi {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Uri _uri(String path, {Map<String, String>? query}) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      final result = decoded['result'];
      if (result is Map<String, dynamic>) {
        final items = result['items'];
        if (items is List) return items;
        final nestedData = result['data'];
        if (nestedData is List) return nestedData;
      }

      final data = decoded['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested is List) return nested;
      }
    }

    return const [];
  }

  static Map<String, dynamic>? _extractObject(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;

      final result = decoded['result'];
      if (result is Map<String, dynamic>) {
        final item = result['item'];
        if (item is Map<String, dynamic>) return item;
        return result;
      }

      return decoded;
    }
    return null;
  }

  static Map<String, dynamic> _buildPayload({
    required String word,
    required String meaning,
    String? partOfSpeech,
    String? ipa,
    String? example,
    String? cefrLevel,
  }) {
    final payload = <String, dynamic>{
      'word': word,
      'meaning': meaning,
    };

    if (partOfSpeech != null && partOfSpeech.trim().isNotEmpty) {
      payload['part_of_speech'] = partOfSpeech.trim();
    }
    if (ipa != null && ipa.trim().isNotEmpty) {
      payload['ipa'] = ipa.trim();
    }
    if (example != null && example.trim().isNotEmpty) {
      payload['example'] = example.trim();
    }
    if (cefrLevel != null && cefrLevel.trim().isNotEmpty) {
      payload['cefr_level'] = cefrLevel.trim();
    }

    return payload;
  }

  /// Fetch vocabularies for a notebook.
  /// Endpoint based on Postman create route: /api/notebooks/{id}/vocabularies
  static Future<List<Vocabulary>> fetchByNotebookId({
    required int notebookId,
    int perPage = 200,
  }) async {
    final uri = _uri(
      '/api/notebooks/$notebookId/vocabularies',
      query: {'per_page': perPage.toString()},
    );

    final response = await ApiService.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Không thể tải danh sách từ vựng (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final list = _extractList(decoded);

    return list
        .whereType<Map>()
        .map((e) => Vocabulary.fromApiJson(Map<String, dynamic>.from(e)))
        .where((v) => v.id != 0 || v.word.isNotEmpty)
        .toList();
  }

  /// Create a vocabulary under a notebook.
  /// POST /api/notebooks/{id}/vocabularies
  static Future<Vocabulary> createInNotebook({
    required int notebookId,
    required String word,
    required String meaning,
    String? partOfSpeech,
    String? ipa,
    String? example,
    String? cefrLevel,
  }) async {
    final uri = _uri('/api/notebooks/$notebookId/vocabularies');
    final response = await ApiService.post(
      uri,
      body: jsonEncode(
        _buildPayload(
          word: word,
          meaning: meaning,
          partOfSpeech: partOfSpeech,
          ipa: ipa,
          example: example,
          cefrLevel: cefrLevel,
        ),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Không thể thêm từ vựng (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final obj = _extractObject(decoded);
    if (obj == null) {
      return Vocabulary(
        id: 0,
        word: word,
        meaning: meaning,
        partOfSpeech: partOfSpeech ?? '',
        ipa: ipa ?? '',
        example: example ?? '',
        cefrLevel: cefrLevel ?? '',
      );
    }
    return Vocabulary.fromApiJson(obj);
  }

  /// Update a vocabulary.
  /// PUT /api/vocabularies/{id}
  static Future<Vocabulary> update({
    required int id,
    required String word,
    required String meaning,
    String? partOfSpeech,
    String? ipa,
    String? example,
    String? cefrLevel,
  }) async {
    final uri = _uri('/api/vocabularies/$id');
    final response = await ApiService.put(
      uri,
      body: jsonEncode(
        _buildPayload(
          word: word,
          meaning: meaning,
          partOfSpeech: partOfSpeech,
          ipa: ipa,
          example: example,
          cefrLevel: cefrLevel,
        ),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Không thể cập nhật từ vựng (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final obj = _extractObject(decoded);
    if (obj == null) {
      return Vocabulary(
        id: id,
        word: word,
        meaning: meaning,
        partOfSpeech: partOfSpeech ?? '',
        ipa: ipa ?? '',
        example: example ?? '',
        cefrLevel: cefrLevel ?? '',
      );
    }
    return Vocabulary.fromApiJson(obj);
  }

  /// Delete a vocabulary.
  /// (Not present in Postman, but consistent with update route)
  /// DELETE /api/vocabularies/{id}
  static Future<void> delete({required int id}) async {
    final uri = _uri('/api/vocabularies/$id');
    final response = await ApiService.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa từ vựng (${response.statusCode}): ${response.body}');
    }
  }

  /// Enrich a word via AI.
  /// POST /api/vocabularies/enrich
  /// Body: { "word": "meticulous" }
  static Future<Map<String, dynamic>> enrich({required String word}) async {
    final uri = _uri('/api/vocabularies/enrich');
    final response = await ApiService.post(
      uri,
      body: jsonEncode({'word': word}),
    );

    if (response.statusCode != 200) {
      
      throw Exception(
        'Không thể điền bằng AI vui lòng thử lại sau',
      );
    }

    final decoded = jsonDecode(response.body);
    final obj = _extractObject(decoded);
    if (obj == null) {
      throw Exception('Dữ liệu AI không hợp lệ');
    }
    return obj;
  }
}
