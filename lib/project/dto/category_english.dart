class CategoryEnglish {
  int noun= 0;
  int adj= 0;
  int verb = 0;
  int adv = 0;
  int A1;
  int A2;
  int B1;
  int B2;
  int C1;
  int C2;
  int totalVocab;


  CategoryEnglish({this.noun = 0, this.adj = 0, this.verb = 0, this.adv = 0,
    this.A1 = 0, this.A2 = 0, this.B1 = 0, this.B2 = 0, this.C1 = 0, this.C2 = 0,this.totalVocab = 1});

  static int _intFromMap(Map<String, dynamic>? map, String key) {
    final v = map?[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory CategoryEnglish.fromJson(Map<String, dynamic> json) {
    final pie = (json['pie_part_of_speech'] is Map)
        ? Map<String, dynamic>.from(json['pie_part_of_speech'] as Map)
        : <String, dynamic>{};

    final bar = (json['bar_cefr_level'] is Map)
        ? Map<String, dynamic>.from(json['bar_cefr_level'] as Map)
        : <String, dynamic>{};

    // API hiện tại trả key: noun, verb, adjective, adverb (có thể thiếu adverb)
    final noun = _intFromMap(pie, 'noun');
    final adj = _intFromMap(pie, 'adj') + _intFromMap(pie, 'adjective');
    final verb = _intFromMap(pie, 'verb');
    final adv = _intFromMap(pie, 'adv') + _intFromMap(pie, 'adverb');

    return CategoryEnglish(
      noun: noun,
      adj: adj,
      verb: verb,
      adv: adv,
      A1: _intFromMap(bar, 'A1'),
      A2: _intFromMap(bar, 'A2'),
      B1: _intFromMap(bar, 'B1'),
      B2: _intFromMap(bar, 'B2'),
      C1: _intFromMap(bar, 'C1'),
      C2: _intFromMap(bar, 'C2'),
      totalVocab: noun + adj + verb + adv,
    );
  }

}