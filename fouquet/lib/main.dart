import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouquet/core/navigation/app_pages.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/theme.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← ajouter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialiser SharedPreferences AVANT runApp
  await SharedPreferences.getInstance();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Le Fouquet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
