import 'package:flutter/material.dart';
import 'package:magic_english_project/project/login/signin.dart';
import 'package:magic_english_project/project/home/home_page.dart';
import '../../services/shared_preferences_service.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  Future<bool> checkLogin() async {
    final bool rememberMe = SharedPreferencesService.instance.getRememberMe();
    if (rememberMe) {
      return true;
    }
    if (!rememberMe) {
      return false;
    }
    return false;

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLogin(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(body: CircularProgressIndicator(),);
        }
        if(snapshot.data == true){
          return const HomePage(); // show dashboard if logged in
        }
        else{
          return const SignIn();
        }
      },
    );
  }
}
