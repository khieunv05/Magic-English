import 'package:flutter/cupertino.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/category_english.dart';

class HomePageProvider extends ChangeNotifier {
  CategoryEnglish? categoryEnglish;
  bool needRedraw = false;
  final Database _db = Database();
  Future<void> initData() async {
    categoryEnglish = await _db.getUserCategoryEnglish();
    notifyListeners();
  }
  void increaseAdj(){
    categoryEnglish?.adj +=1;
    categoryEnglish?.totalVocab +=1;
    notifyListeners();
  }
  void increaseNoun(){
    categoryEnglish?.noun +=1;
    categoryEnglish?.totalVocab +=1;
    notifyListeners();
  }
  void increaseAdv(){
    categoryEnglish?.adv +=1;
    categoryEnglish?.totalVocab +=1;
    notifyListeners();
  }
  void increaseVerb(){
    categoryEnglish?.verb +=1;
    categoryEnglish?.totalVocab +=1;
    notifyListeners();
  }
  void increaseA1(){
    categoryEnglish?.A1 +=1;
    notifyListeners();
  }
  void increaseA2(){
    categoryEnglish?.A2 +=1;
    notifyListeners();
  }
  void increaseB1(){
    categoryEnglish?.B1 +=1;
    notifyListeners();
  }
  void increaseB2(){
    categoryEnglish?.B2 +=1;
    notifyListeners();
  }
  void increaseC1(){
    categoryEnglish?.C1 +=1;
    notifyListeners();
  }
  void increaseC2(){
    categoryEnglish?.C2 +=1;
    notifyListeners();
  }
}