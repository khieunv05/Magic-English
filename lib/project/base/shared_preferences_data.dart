import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesData {
  static late final SharedPreferences sharedPreferences;
  static Future<void> initSharedPreferences() async{
    sharedPreferences = await SharedPreferences.getInstance();
  }
}