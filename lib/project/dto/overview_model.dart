class OverviewModel {
  final bool status;
  final String message;
  final OverviewResult? result;

  OverviewModel({required this.status, required this.message, this.result});

  factory OverviewModel.fromJson(Map<String, dynamic> json) {
    return OverviewModel(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      result: json['result'] != null ? OverviewResult.fromJson(json['result']) : null,
    );
  }
}

class OverviewResult {
  final int totalVocabularyLearned;
  final StreakInfo streak;
  final List<Badge> badges;

  OverviewResult({required this.totalVocabularyLearned, required this.streak, required this.badges});

  factory OverviewResult.fromJson(Map<String, dynamic> json) {
    return OverviewResult(
      totalVocabularyLearned: json['total_vocabulary_learned'] ?? 0,
      streak: StreakInfo.fromJson(json['streak'] ?? {}),
      badges: json['badges'] != null
          ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList()
          : [],
    );
  }
}

class StreakInfo {
  final int streak;
  final bool todayActive;
  final String lastActiveDate;

  StreakInfo({required this.streak, required this.todayActive, required this.lastActiveDate});

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      streak: json['streak'] ?? 0,
      todayActive: json['today_active'] ?? false,
      lastActiveDate: json['last_active_date'] ?? "",
    );
  }
}

class Badge {
  final String name;
  Badge({required this.name});
  factory Badge.fromJson(Map<String, dynamic> json) => Badge(name: json['name'] ?? "");
}