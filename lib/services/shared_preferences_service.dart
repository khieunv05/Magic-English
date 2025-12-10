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

  Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool('remember_me', value);
  }
}

