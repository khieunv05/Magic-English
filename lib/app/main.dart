import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/shared_preferences_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  await SharedPreferencesService.instance.init();
  runApp(const App());
}

