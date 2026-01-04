import 'package:flutter/material.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:magic_english_project/app/app_router.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class App extends StatelessWidget {
  App({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.appTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
