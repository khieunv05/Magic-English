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