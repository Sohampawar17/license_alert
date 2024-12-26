import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../router.router.dart';
import 'login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Color myColor;
  late Size mediaSize;
 bool isPasswordVisible = false;
  bool rememberUser = false;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return  ViewModelBuilder<LoginViewModel>.reactive(
  viewModelBuilder: () => LoginViewModel(),
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
      body: Stack(children: [
        Positioned(top: 50, child: _buildTop()),
        Positioned(bottom: 0, child: _buildBottom(model)),
      ]),
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
            Icons.notification_important_outlined,
            size: 100,
            color: Colors.white,
          ),
          Text(
            "License Alert",
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

  Widget _buildBottom(LoginViewModel model) {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        )),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(model),
        ),
      ),
    );
  }

  Widget _buildForm(LoginViewModel model) {
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
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 60),
        _buildGreyText("Email address"),
        _buildInputField(model.usernameController, validator: model.validateUsername),
        const SizedBox(height: 40),
        _buildGreyText("Password"),
        _buildInputField(model.passwordController, isPassword: true, validator: model.validatePassword),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        const SizedBox(height: 20),
        _buildLoginButton(model),
        const SizedBox(height: 20),
        _buildSignUpOption(),
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

   Widget _buildInputField(TextEditingController controller, {isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible; // Toggle visibility
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword ? !isPasswordVisible : false, // Toggle between obscure and not
      validator: validator,
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
                value: rememberUser,
                onChanged: (value) {
                  setState(() {
                    rememberUser = value!;
                  });
                }),
            _buildGreyText("Remember me"),
          ],
        ),
        TextButton(
            onPressed: () {}, child: _buildGreyText("I forgot my password"))
      ],
    );
  }

 Widget _buildLoginButton(LoginViewModel model) {
  return ElevatedButton(
    onPressed: model.isloading ? null : () {
      debugPrint("Email : ${model.usernameController.text}");
      debugPrint("Password : ${model.passwordController.text}");
      model.loginwithUsernamePassword(context);
    },
    style: ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      elevation: 10,
      shadowColor: myColor,
      minimumSize: const Size.fromHeight(60),
    ),
    child: model.isloading
        ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
        : const Text("LOGIN"),
  );
}


  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () {
            debugPrint("Sign Up button pressed");
            Navigator.pushNamed(context, Routes.signUpPage);
          },
          child: Text("Sign up", style: TextStyle(color: myColor)),
        )
      ],
    );
  }
}
