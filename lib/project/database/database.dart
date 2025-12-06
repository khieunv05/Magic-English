import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_project/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_project/project/dto/writingdto.dart';
class Database{
  static Future<void> addToParagraph(WritingDto writingDto)async{
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    CollectionReference path = FirebaseFirestore.instance.collection('users')
        .doc(user.uid).collection('writing_history');
    await path.add(writingDto.toMap());
  }
}