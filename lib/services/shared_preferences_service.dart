import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService._privateConstructor();
  static final SharedPreferencesService instance = SharedPreferencesService._privateConstructor();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool getRememberMe() {
    return _prefs?.getBool('remember_me') ?? false;
  }
  Future<void> clear() async{
    await _prefs?.clear();
  }
  String getAccessToken(){
    return _prefs?.getString('accessToken')?? '';
  }
  Future<void> setAccessToken(String accessToken) async{
    await _prefs?.setString('accessToken', accessToken);
  }
  Future<void> setRememberMe(bool value,String email,String password) async {
    await _prefs?.setBool('remember_me', value);
    if(value == true){
      await _prefs?.setString('email', email);
      await _prefs?.setString('password', password);
    }
  }
  String getEmail(){
    return _prefs?.getString('email')??"";
  }
  String getPassword(){
    return _prefs?.getString('password')??"";
  }
}

