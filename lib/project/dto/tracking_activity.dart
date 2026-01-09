class TrackingActivity {
  final int id;
  final int userId;
  final int? notebookId;
  final String type;
  final int relatedId;
  final DateTime? activityDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final TrackingActivityNotebook? notebook;
  final TrackingActivityVocabulary? vocabulary;
  final TrackingActivityGrammarCheck? grammarCheck;

  TrackingActivity({
    required this.id,
    required this.userId,
    required this.notebookId,
    required this.type,
    required this.relatedId,
    required this.activityDate,
    required this.createdAt,
    required this.updatedAt,
    required this.notebook,
    required this.vocabulary,
    required this.grammarCheck,
  });

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.trim().isNotEmpty) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  factory TrackingActivity.fromJson(Map<String, dynamic> json) {
    return TrackingActivity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      notebookId: (json['notebook_id'] as num?)?.toInt(),
      type: (json['type'] ?? '').toString(),
      relatedId: (json['related_id'] as num?)?.toInt() ?? 0,
      activityDate: _tryParseDate(json['activity_date']),
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
      notebook: TrackingActivityNotebook.maybeFromJson(json['notebook']),
      vocabulary: TrackingActivityVocabulary.maybeFromJson(json['vocabulary']),
      grammarCheck: TrackingActivityGrammarCheck.maybeFromJson(json['grammar_check']),
    );
  }
}

class TrackingActivityNotebook {
  final int id;
  final String name;

  TrackingActivityNotebook({
    required this.id,
    required this.name,
  });

  static TrackingActivityNotebook? maybeFromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    return TrackingActivityNotebook(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: (map['name'] ?? '').toString(),
    );
  }
}

class TrackingActivityVocabulary {
  final int id;
  final int notebookId;
  final String word;
  final String meaning;
  final String partOfSpeech;
  final String cefrLevel;
  final DateTime? createdAt;

  TrackingActivityVocabulary({
    required this.id,
    required this.notebookId,
    required this.word,
    required this.meaning,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.createdAt,
  });

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static TrackingActivityVocabulary? maybeFromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    return TrackingActivityVocabulary(
      id: (map['id'] as num?)?.toInt() ?? 0,
      notebookId: (map['notebook_id'] as num?)?.toInt() ?? 0,
      word: (map['word'] ?? '').toString(),
      meaning: (map['meaning'] ?? '').toString(),
      partOfSpeech: (map['part_of_speech'] ?? '').toString(),
      cefrLevel: (map['cefr_level'] ?? '').toString(),
      createdAt: _tryParseDate(map['created_at']),
    );
  }
}

class TrackingActivityGrammarCheck {
  final int id;
  final num? score;
  final String originalText;
  final List<String> errors;
  final List<String> suggestions;
  final int errorsCount;
  final int suggestionsCount;
  final DateTime? createdAt;

  TrackingActivityGrammarCheck({
    required this.id,
    required this.score,
    required this.originalText,
    required this.errors,
    required this.suggestions,
    required this.errorsCount,
    required this.suggestionsCount,
    required this.createdAt,
  });

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v.map((e) => (e ?? '').toString()).where((s) => s.trim().isNotEmpty).toList(growable: false);
    }
    return const <String>[];
  }

  static TrackingActivityGrammarCheck? maybeFromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    return TrackingActivityGrammarCheck(
      id: (map['id'] as num?)?.toInt() ?? 0,
      score: map['score'] as num?,
      originalText: (map['original_text'] ?? '').toString(),
      errors: _stringList(map['errors']),
      suggestions: _stringList(map['suggestions']),
      errorsCount: (map['errors_count'] as num?)?.toInt() ?? 0,
      suggestionsCount: (map['suggestions_count'] as num?)?.toInt() ?? 0,
      createdAt: _tryParseDate(map['created_at']),
    );
  }
}

class TrackingActivitiesPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  TrackingActivitiesPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory TrackingActivitiesPagination.fromJson(Map<String, dynamic> json) {
    return TrackingActivitiesPagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      perPage: (json['per_page'] as num?)?.toInt() ?? 0,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}

class TrackingActivitiesResponse {
  final bool status;
  final String message;
  final List<TrackingActivity> items;
  final TrackingActivitiesPagination? pagination;

  TrackingActivitiesResponse({
    required this.status,
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory TrackingActivitiesResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final resultMap = result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};

    final rawItems = resultMap['items'];
    final itemsList = rawItems is List ? rawItems : const [];

    final rawPagination = resultMap['pagination'];
    final paginationMap = rawPagination is Map
      ? Map<String, dynamic>.from(rawPagination)
        : null;

    return TrackingActivitiesResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      items: itemsList
          .whereType<Map>()
          .map((e) => TrackingActivity.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      pagination: paginationMap == null
          ? null
          : TrackingActivitiesPagination.fromJson(paginationMap),
    );
  }
}
