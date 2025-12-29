class Vocabulary {
  final int id;
  final String word;
  final String meaning;
  final String partOfSpeech;
  final String ipa;
  final String example;
  final String cefrLevel;

  const Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    required this.partOfSpeech,
    required this.ipa,
    required this.example,
    required this.cefrLevel,
  });

  static Vocabulary fromApiJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final word = (json['word'] ?? json['name'] ?? '').toString();
    final meaning = (json['meaning'] ?? '').toString();
    final partOfSpeech = (json['part_of_speech'] ?? json['type'] ?? '').toString();
    final ipa = (json['ipa'] ?? json['phonetic'] ?? '').toString();
    final example = (json['example'] ?? '').toString();
    final cefrLevel = (json['cefr_level'] ?? json['level'] ?? '').toString();

    return Vocabulary(
      id: id,
      word: word,
      meaning: meaning,
      partOfSpeech: partOfSpeech,
      ipa: ipa,
      example: example,
      cefrLevel: cefrLevel,
    );
  }
}
