import 'package:flutter/cupertino.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/user.dart';

class UserProvider extends ChangeNotifier{
  bool isEditing = false;
  User? user;
  void setUser(User u){
    user = u;
    notifyListeners();
  }
  Future<void> getUserData() async{
    Database db = Database();
    user = await db.getUserData();
    notifyListeners();
  }
  void logOut(){
    user = null;
    notifyListeners();
  }
  void startEditing(){
    isEditing = true;
    notifyListeners();
  }
  void stopEditing(){
    isEditing = false;
    notifyListeners();
  }
}