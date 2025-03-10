import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:license_alert/router.router.dart';
import 'package:license_alert/themes/custom_color.g.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';
import 'router.locator.dart';
import 'screens/splash_screen.dart';
import 'themes/color_schemes.g.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupLocator();

  await AwesomeNotifications().initialize(
    null, // Default icon (null means it uses the app icon)
    [
      NotificationChannel(
        channelKey: 'puc_expiry_channel',
        channelName: 'PUC Expiry Notifications',
        channelDescription: 'Notifies when PUC is about to expire',
        defaultColor: Colors.blueAccent,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        playSound: true,
        defaultRingtoneType: DefaultRingtoneType.Notification,
      ),
      NotificationChannel(
        channelKey: 'license_expiry_channel',
        channelName: 'License Expiry Notifications',
        channelDescription: 'Notifies when License is about to expire',
        defaultColor: Colors.redAccent,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        playSound: true,
        defaultRingtoneType: DefaultRingtoneType.Notification,
      ),
    ],
    debug: true,
  );

  runApp(const MyApp());
  
}

Future<void> ensureNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isDenied || status.isLimited) {
    // Request permission again
    status = await Permission.notification.request();
  }

  if (status.isPermanentlyDenied) {
    // If permanently denied, direct user to app settings
    print("⚠️ Notification permission permanently denied. Redirecting to settings.");
    await openAppSettings();
  } else if (status.isGranted) {
    print("✅ Notification permission granted.");
  } else {
    print("🚨 Notification permission denied.");
  }
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
