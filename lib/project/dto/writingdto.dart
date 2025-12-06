import 'package:cloud_firestore/cloud_firestore.dart';

class WritingDto{
  String? id;
  int point = 0;
  String content = '';
  List<String> errors = [];
  String suggests = '';
  DateTime? createdAt;
  WritingDto(this.point, this.content, this.errors, this.suggests,[this.id]);



  WritingDto.fromMap(String this.id,Map<String,dynamic> data){
    content = data['content'] ??  '';
    errors = List<String>.from(data['errors'] ?? []);
    point = data['point'] ?? 0;
    suggests = data['suggests'] ?? '';
    createdAt = (data['date'] as Timestamp?)?.toDate();
  }
  Map<String, dynamic> toMap(){
    return {
      'point': point,
      'content': content,
      'errors': errors,
      'suggests':suggests,
      'date': createdAt ?? FieldValue.serverTimestamp()
    };
  }

}