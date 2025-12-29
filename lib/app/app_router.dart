import 'package:flutter/material.dart';
import 'package:magic_english_project/intro/first_intro.dart'; // Đảm bảo đường dẫn đúng file Intro của bạn
import 'package:magic_english_project/intro/onboarding_screen.dart';
import 'package:magic_english_project/project/login/signin.dart';
import 'package:magic_english_project/project/home/home_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/signin';
  static const String home = '/home';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignIn());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))));
    }
  }
}