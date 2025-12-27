class CategoryEnglish {
  double noun= 0;
  double adj= 0;
  double verb = 0;
  double adv = 0;
  double A1;
  double A2;
  double B1;
  double B2;
  double C1;
  double C2;
  double totalVocab;


  CategoryEnglish({this.noun = 0, this.adj = 0, this.verb = 0, this.adv = 0,
    this.A1 = 0, this.A2 = 0, this.B1 = 0, this.B2 = 0, this.C1 = 0, this.C2 = 0,this.totalVocab = 1});

  factory CategoryEnglish.fromJson(Map<String,dynamic> json){
    return CategoryEnglish(
      noun: json['pie_part_of_speech']['noun'],
      adj: json['pie_part_of_speech']['adj'],
      verb:  json['pie_part_of_speech']['verb'],
      adv: json['pie_part_of_speech']['adv'],
      A1: json['bar_cefr_level']['A1'],
      A2: json['bar_cefr_level']['A2'],
      B1:  json['bar_cefr_level']['B1'],
      B2:  json['bar_cefr_level']['B2'],
      C1:  json['bar_cefr_level']['C1'],
      C2:  json['bar_cefr_level']['C2'],
      totalVocab: json['pie_part_of_speech']['noun']+json['pie_part_of_speech']['adj']
        + json['pie_part_of_speech']['verb'] +  json['pie_part_of_speech']['adv']
    );
  }

}