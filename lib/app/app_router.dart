import 'package:flutter/material.dart';
import 'package:magic_english_project/project/login/mainscreen.dart';
import 'package:magic_english_project/project/login/signin.dart';
import 'package:magic_english_project/project/pointanderror/historypoint.dart';
 import 'package:magic_english_project/intro/first_intro.dart';

class AppRouter {
  static const String intro = '/intro';
  static const String mainScreen = '/';
  static const String signIn = '/signin';
  static const String history = '/history';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignIn());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPoint());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))));
    }
  }
}