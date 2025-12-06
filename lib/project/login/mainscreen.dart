import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/project/login/signin.dart';
import 'package:test_project/project/pointanderror/historypoint.dart';
import 'package:test_project/project/theme/apptheme.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: AppTheme.appTheme,
    home: const MainScreen(),
  ));
}
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  Future<bool> checkLogin() async {
    final pref = await SharedPreferences.getInstance();
    bool? rememberMe = pref.getBool('remember_me');
    final user = FirebaseAuth.instance.currentUser;
    if(user != null && rememberMe!){
      return true;
    }
    else if(user != null && rememberMe! == false){
      FirebaseAuth.instance.signOut();
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
          return const HistoryPoint();
        }
        else{
          return const SignIn();
        }
      },
    );
  }
}
