
class WritingDto{
  int? id;
  int score = 0;
  String originalText = '';
  List<String>? errors = [];
  List<String>? suggestions = [];
  WritingDto(this.score, this.originalText, this.errors, this.suggestions,[this.id]);



  WritingDto.fromMap(Map<String,dynamic> data){
    id = data['id'];
    originalText = data['original_text'] ??  '';
    errors = List<String>.from(data['errors'] ?? []);
    score = data['score'] ?? 0;
    suggestions = List<String>.from(data['suggestions'] ?? []);
    //createdAt = (data['date'] as Timestamp?)?.toDate();
  }
  Map<String, dynamic> toMap(){
    return {
      'score': score,
      'original_text': originalText,
      'errors': errors,
      'suggestions':suggestions,
      //'date': createdAt ?? FieldValue.serverTimestamp()
    };
  }

}