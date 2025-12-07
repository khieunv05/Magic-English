import 'package:flutter/material.dart';
import 'package:test_project/project/login/mainscreen.dart';
import 'package:test_project/project/login/signin.dart';
import 'package:test_project/project/pointanderror/historypoint.dart';

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignIn());
      case '/history':
        return MaterialPageRoute(builder: (_) => const HistoryPoint());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))));
    }
  }
}
