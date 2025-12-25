import 'package:flutter/material.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';

class ParagraphProvider extends ChangeNotifier{
  final Database _db = Database();
  List<WritingDto>? writingHistory;
  bool isLoading = false;
  Future<void> initData()async{
    isLoading = true;
    notifyListeners();
    try{
    writingHistory = await _db.getAllParagraph();
    isLoading = false;
    }
    catch(err){
      print(err.toString());
    }
    notifyListeners();
  }
  void clearData(){
    writingHistory = null;
    notifyListeners();
  }
  Future<WritingDto?> addData(String text)async{
    if(writingHistory == null){
      return null;
    }
    WritingDto writingDto = await _db.addParagraph(text);
    writingHistory!.insert(0,writingDto);
    notifyListeners();
    return writingDto;
  }
  Future<String> deleteData(int? id,int index) async{
    if(writingHistory == null){
      return 'Chưa có data lịch sử viết';
    }
    isLoading = true;
    notifyListeners();
    String message = await _db.deleteParagraph(id, index);
    writingHistory!.removeAt(index);
    isLoading = false;
    notifyListeners();
    return message;
  }
}