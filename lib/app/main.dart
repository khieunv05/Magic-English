import 'package:flutter/material.dart';
import 'package:magic_english_project/project/base/shared_preferences_data.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'package:magic_english_project/project/provider/userprovider.dart';
import 'package:provider/provider.dart';
import '../services/shared_preferences_service.dart';
import 'app.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.instance.init();
  await SharedPreferencesData.initSharedPreferences();
  runApp(
    MultiProvider(providers: [ChangeNotifierProvider(create: (_)=> UserProvider(),),
      ChangeNotifierProvider(create: (_)=>ParagraphProvider())
    ],
    child: App(),),);
}

