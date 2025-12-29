class Notebook {
  final int id;
  final String name;
  final String description;
  final bool isFavorite;
  final int vocabulariesCount;
  final DateTime? createdAt;

  const Notebook({
    required this.id,
    required this.name,
    required this.description,
    required this.isFavorite,
    required this.vocabulariesCount,
    required this.createdAt,
  });

  Notebook copyWith({
    int? id,
    String? name,
    String? description,
    bool? isFavorite,
    int? vocabulariesCount,
    DateTime? createdAt,
  }) {
    return Notebook(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      vocabulariesCount: vocabulariesCount ?? this.vocabulariesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Notebook fromApiJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final name = (json['name'] ?? json['title'] ?? '').toString();
    final description = (json['description'] ?? '').toString();

    final favoriteRaw = json['is_favorite'] ?? json['isFavorite'] ?? false;
    final isFavorite = favoriteRaw == true || favoriteRaw.toString().toLowerCase() == 'true' || favoriteRaw.toString() == '1';

    final countRaw = json['vocabularies_count'] ?? json['vocab_count'] ?? json['count'] ?? 0;
    final vocabulariesCount = countRaw is int ? countRaw : int.tryParse(countRaw.toString()) ?? 0;

    DateTime? createdAt;
    final createdRaw =
        json['created_at'] ?? json['createdAt'] ?? json['created'] ?? json['created_date'];
    if (createdRaw != null) {
      createdAt = _tryParseApiDate(createdRaw.toString());
    }

    return Notebook(
      id: id,
      name: name,
      description: description,
      isFavorite: isFavorite,
      vocabulariesCount: vocabulariesCount,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'description': description,
      'is_favorite': isFavorite,
    };
  }

  static DateTime? _tryParseApiDate(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // Example: "24-12-2025 15:15:00" (dd-MM-yyyy HH:mm:ss)
    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?$')
        .firstMatch(raw.trim());
    if (match == null) return null;

    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final year = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    final second = int.tryParse(match.group(6) ?? '0') ?? 0;
    if (day == null || month == null || year == null || hour == null || minute == null) {
      return null;
    }

    return DateTime(year, month, day, hour, minute, second);
  }
}
