
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import '../../services/authentication_serice.dart';
import '../home/home_screen.dart';

class LoginViewModel extends BaseViewModel {
  final formGlobalKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  var fcmToken = "";
  bool obscurePassword = true;
  bool isloading = false;
  bool rememberMe = false;
bool res=false;
 Future<void> initialise() async {
  rememberMe = true;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  rememberMe = prefs.getBool('rememberMe') ?? false;
  if (rememberMe) {
    usernameController.text = prefs.getString('username') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
    Logger().i(usernameController.text);
    Logger().i(passwordController.text);
    Logger().i(rememberMe);
  }
  notifyListeners();
}



  void changeRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void loginwithUsernamePassword(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    
    notifyListeners();
    
    String username = usernameController.text;
    String password = passwordController.text;
    
    Logger().i(username);
    Logger().i(password);
    
    if (formGlobalKey.currentState!.validate()) {
      isloading = true;
      res = await AuthenticationService().signInWithEmailAndPassword(username, password);
      notifyListeners();
      
      if (res) {
        // Remember login credentials
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          await prefs.setString('username', usernameController.text);
          await prefs.setString('password', passwordController.text);
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('username');
          await prefs.remove('password');
          await prefs.setBool('rememberMe', false);
        }

        isloading = false;
        
        // Transition to home screen
        if (context.mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Define a fade transition (you can adjust this to other types as needed)
                var tween = Tween(begin: 0.0, end: 1.0);
                var fadeAnimation = animation.drive(tween);
                
                return FadeTransition(opacity: fadeAnimation, child: child);
              },
            ),
          );
        }
      } else {
        isloading = false;
      }
    }
  } else {
    // If no internet connection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        showCloseIcon: true,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.wifi_off_sharp, color: Colors.white, size: 25),
            SizedBox(width: 20),
            Text('Please connect your device to the internet', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
    isloading = false;
  }
}

  String? validateUsername(username) {
    if (username.toString().isEmpty) {
      return "Enter a valid username";
    }
    return null;
  }

  String? validatePassword(password) {
    if (password.toString().isEmpty) {
      return "Enter a Password";
    }
    return null;
  }

  @override
void dispose() {
  usernameController.dispose();
  passwordController.dispose();
  focusNode.dispose();
  super.dispose();
}

}
