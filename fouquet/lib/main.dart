import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_router.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Portrait uniquement ───────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Style barre système ───────
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

      // ── Navigation ───────
      initialRoute: AppRoutes.splash,
      getPages: AppRouter.routes,

      // ── Transition par défaut ───────
      defaultTransition: Transition.fadeIn,
    );
  }
}
