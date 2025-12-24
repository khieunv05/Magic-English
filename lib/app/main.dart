import 'package:flutter/material.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'package:magic_english_project/project/provider/userprovider.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/shared_preferences_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  await SharedPreferencesService.instance.init();
  runApp(
    MultiProvider(providers: [ChangeNotifierProvider(create: (_)=> UserProvider(),),
      ChangeNotifierProvider(create: (_)=>ParagraphProvider())
    ],
    child: App(),),);
}

