import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return ViewModelBuilder<LoginViewModel>.reactive(
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
          body: Stack(
            children: [
              Positioned(top: 80, child: _buildTop()),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 100,
            color: Colors.white,
          ),
          Text(
            "Welcome Back!",
            style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
                letterSpacing: 1.5),
          )
        ],
      ),
    );
  }

  Widget _buildBottom(LoginViewModel model) {
    return Container(
      width: mediaSize.width,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: _buildForm(model),
    );
  }

  Widget _buildForm(LoginViewModel model) {
    return Form(
      key: model.formGlobalKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Login",
            style: GoogleFonts.lato(
                color: myColor, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildGreyText("Email Address"),
          _buildInputField(model.usernameController,
              validator: model.validateUsername),
          const SizedBox(height: 20),
          _buildGreyText("Password"),
          _buildInputField(model.passwordController,
              isPassword: true, validator: model.validatePassword),
          const SizedBox(height: 20),
          _buildRememberForgot(),
          const SizedBox(height: 30),
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
      style: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword ? !isPasswordVisible : false,
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
            onPressed: () {},
            child: _buildGreyText("Forgot Password?"))
      ],
    );
  }

  Widget _buildLoginButton(LoginViewModel model) {
    return ElevatedButton(
      onPressed: model.isloading
          ? null
          : () => model.loginwithUsernamePassword(context),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        minimumSize: const Size.fromHeight(55),
        backgroundColor: myColor,
      ),
      child: model.isloading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text("LOGIN", style: GoogleFonts.lato(fontSize: 18,color: Colors.white)),
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
            style: GoogleFonts.lato(color: Colors.grey)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, Routes.signUpPage),
          child: Text("Sign up", style: GoogleFonts.lato(color: myColor)),
        )
      ],
    );
  }
}
