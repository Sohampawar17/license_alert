import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:license_alert/router.router.dart';
import 'package:license_alert/themes/custom_color.g.dart';
import 'package:stacked_services/stacked_services.dart';
import 'screens/splash_screen.dart';
import 'themes/color_schemes.g.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme, // Use fixed light color scheme
        extensions: [lightCustomColors],
      ),
      home:  const SplashScreen(),
    );
  }
}
