import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../services/authentication_serice.dart';
import '../login_screen/login_screen.dart';

class SignUpViewModel extends BaseViewModel {
  // Controllers for form fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Global key for form validation
  final GlobalKey<FormState> formGlobalKey = GlobalKey<FormState>();
  bool res = false;
  bool isloading = false;

  // Validation for email address
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    // You can add more validation logic here, like regex for email format
    return null;
  }

  // Validation for password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    // Minimum password length validation
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validation for confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Sign up method
 Future<void> signUpWithUsernamePassword(BuildContext context) async {
  if (!formGlobalKey.currentState!.validate()) {
    return;
  }

  setBusy(true);
  try {
    String username = usernameController.text;
    String password = confirmPasswordController.text;
    
    // Perform the sign-up
    res = await AuthenticationService().signUpWithEmailAndPassword(username, password);
    await Future.delayed(const Duration(seconds: 2));  // simulate some delay
    
    if (res) {
      setBusy(false);
      
      // Use custom transition here after sign-up success
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Define a sliding transition
              const begin = Offset(1.0, 0.0); // Slide from right
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    } else {
      setBusy(false);
    }
  } finally {
    setBusy(false);
  }
}

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Initialize any necessary data when the view model is ready
  void initialise() {
    // Any setup can be done here (e.g., fetching user info, etc.)
  }
}
