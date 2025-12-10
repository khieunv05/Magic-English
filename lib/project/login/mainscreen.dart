import 'package:flutter/material.dart';
import 'package:test_project/project/login/signin.dart';
import 'package:test_project/project/home/home_page.dart';
import '../../services/shared_preferences_service.dart';
import '../../services/firebase_service.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  Future<bool> checkLogin() async {
    final bool rememberMe = SharedPreferencesService.instance.getRememberMe();
    final user = FirebaseService.instance.currentUser;
    if (user != null && rememberMe) {
      return true;
    }
    if (user != null && !rememberMe) {
      await FirebaseService.instance.signOut();
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
