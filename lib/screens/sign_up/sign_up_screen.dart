import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../login_screen/login_screen.dart';
import 'sign_up_viewmodel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late Color myColor;
  late Size mediaSize;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool rememberUser = false;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return ViewModelBuilder<SignUpViewModel>.reactive(
      viewModelBuilder: () => SignUpViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          color: myColor,
          image: DecorationImage(
            image: const AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned(top: 50, child: _buildTop()),
              Positioned(bottom: 0, child: _buildBottom(model)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Colors.white,
          ),
          Text(
            "Create Account",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                letterSpacing: 2),
          )
        ],
      ),
    );
  }

  Widget _buildBottom(SignUpViewModel model) {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(model),
        ),
      ),
    );
  }

  Widget _buildForm(SignUpViewModel model) {
    return Form(
      key: model.formGlobalKey,  // Use form key
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome",
            style: TextStyle(
                color: myColor, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          _buildGreyText("Please fill in the details to create an account"),
          const SizedBox(height: 60),
          _buildGreyText("Email address"),
          _buildInputField(model.usernameController, validator: model.validateUsername),
          const SizedBox(height: 40),
          _buildGreyText("Password"),
          _buildInputField(model.passwordController, isPassword: true, validator: model.validatePassword),
          const SizedBox(height: 40),
          _buildGreyText("Confirm Password"),
          _buildInputField(model.confirmPasswordController, isPassword: true, validator: model.validateConfirmPassword),
          const SizedBox(height: 20),
          _buildSignUpButton(model),
          const SizedBox(height: 20),
          _buildSignInOption(),
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  // Password visibility toggle
  Widget _buildInputField(TextEditingController controller, {isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: myColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPassword ? (isPasswordVisible ? Icons.visibility : Icons.visibility_off) : Icons.done,
                  color: myColor,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      isPasswordVisible = !isPasswordVisible;
                    } else {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword ? !isPasswordVisible : false,
      validator: validator,
    );
  }

  Widget _buildSignUpButton(SignUpViewModel model) {
    return ElevatedButton(
      onPressed: model.isloading
          ? null
          : () {
              debugPrint("Email : ${model.usernameController.text}");
              debugPrint("Password : ${model.passwordController.text}");
              debugPrint("Confirm Password : ${model.confirmPasswordController.text}");
              model.signUpWithUsernamePassword(context);
            },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: model.isloading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("SIGN UP"),
    );
  }

  Widget _buildSignInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () {
            // Use custom page transition here
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // You can change this transition
                  const begin = Offset(1.0, 0.0); // Slide from right
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          },
          child: Text("Sign in", style: TextStyle(color: myColor)),
        )
      ],
    );
  }
}
