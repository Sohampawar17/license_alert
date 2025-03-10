import 'package:flutter/material.dart';
import '../services/authentication_serice.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthenticationService auth=AuthenticationService();
  @override
  void initState() {
    super.initState();
    auth.isLogin(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen background image
          Image.asset(
            'assets/images/logo.png',  // Make sure your image path is correct
            fit: BoxFit.cover,           // This makes the image fill the entire screen
          ),
          // Overlay content (like text or logo)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or image (This will stay centered)
              
              ],
            ),
          ),
        ],
      ),
    );
  }
}
