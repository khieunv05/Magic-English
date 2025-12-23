import 'package:flutter/cupertino.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/user.dart';

class UserProvider extends ChangeNotifier{
  bool isEditing = false;
  User? user = User(
    name: 'Nguyễn Văn A',
    email: 'abc@gmail.com',
    dateOfBirth: '10/11/2004',
    phone: '0987654321',
    gender: 'Nam',
  );
  void setUser(User u){
    user = u;
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