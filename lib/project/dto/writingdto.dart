import 'package:cloud_firestore/cloud_firestore.dart';

class WritingDto{
  String? id;
  int point = 0;
  String content = '';
  List<String> mistakes = [];
  String suggests = '';
  DateTime? createdAt;
  WritingDto(this.point, this.content, this.mistakes, this.suggests,[this.id]);



  WritingDto.fromMap(Map<String,dynamic> data){
    id = data['_id'];
    content = data['content'] ??  '';
    mistakes = List<String>.from(data['mistakes'] ?? []);
    point = data['point'] ?? 0;
    suggests = data['suggest'] ?? '';
    //createdAt = (data['date'] as Timestamp?)?.toDate();
  }
  Map<String, dynamic> toMap(){
    return {
      'point': point,
      'content': content,
      'mistakes': mistakes,
      'suggests':suggests,
      //'date': createdAt ?? FieldValue.serverTimestamp()
    };
  }

}