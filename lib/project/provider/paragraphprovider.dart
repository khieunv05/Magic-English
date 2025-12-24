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
  Future<WritingDto?> addData(String text)async{
    if(writingHistory == null){
      return null;
    }
    WritingDto writingDto = await _db.addParagraph(text);
    writingHistory!.insert(0,writingDto);
    notifyListeners();
    return writingDto;
    
  }
}