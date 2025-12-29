import 'dart:convert';

import 'package:magic_english_project/api_service/apiservice.dart';
import 'package:magic_english_project/core/config/api_config.dart';
import 'package:magic_english_project/project/dto/notebook.dart';

class NotebookApi {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Uri _uri(String path, {Map<String, String>? query}) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      // Common patterns: { result: { items: [...] } }
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
        // Some APIs wrap single object in result.item
        final item = result['item'];
        if (item is Map<String, dynamic>) return item;
        return result;
      }
      return decoded;
    }
    return null;
  }

  static Future<List<Notebook>> fetchNotebooks({int perPage = 50}) async {
    final uri = _uri('/api/notebooks', query: {'per_page': perPage.toString()});
    final response = await ApiService.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách sổ tay');
    }

    final decoded = jsonDecode(response.body);
    final list = _extractList(decoded);

    return list
        .whereType<Map>()
        .map((e) => Notebook.fromApiJson(Map<String, dynamic>.from(e)))
        .where((n) => n.id != 0)
        .toList();
  }

  static Future<Notebook> create({
    required String name,
    String description = '',
    bool isFavorite = false,
  }) async {
    final uri = _uri('/api/notebooks');
    final response = await ApiService.post(
      uri,
      body: jsonEncode({
        'name': name,
        'description': description,
        'is_favorite': isFavorite,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Không thể tạo sổ tay');
    }

    final decoded = jsonDecode(response.body);
    final obj = _extractObject(decoded);
    if (obj == null) {
      return Notebook(
        id: 0,
        name: name,
        description: description,
        isFavorite: isFavorite,
        // Provide a safe default for vocabulariesCount when API doesn't return the created object
        vocabulariesCount: 0,
        createdAt: null,
      );
    }
    return Notebook.fromApiJson(obj);
  }

  static Future<Notebook> update({
    required Notebook notebook,
    String? name,
    String? description,
    bool? isFavorite,
  }) async {
    final uri = _uri('/api/notebooks/${notebook.id}');
    final response = await ApiService.put(
      uri,
      body: jsonEncode({
        'name': name ?? notebook.name,
        'description': description ?? notebook.description,
        'is_favorite': isFavorite ?? notebook.isFavorite,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật sổ tay');
    }

    final decoded = jsonDecode(response.body);
    final obj = _extractObject(decoded);
    if (obj == null) return notebook;
    return Notebook.fromApiJson(obj);
  }

  static Future<void> delete({required int id}) async {
    final uri = _uri('/api/notebooks/$id');
    final response = await ApiService.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa sổ tay');
    }
  }
}
