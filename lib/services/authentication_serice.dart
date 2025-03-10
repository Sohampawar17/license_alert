
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../router.router.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
 final databaseRef = FirebaseFirestore.instance.collection('users');

void isLogin(BuildContext context){
final user=  _firebaseAuth.currentUser;
if(user != null){
  Timer(const Duration(seconds: 3), ()=>Navigator.popAndPushNamed(context,Routes.homeScreen));
}
else{
  Timer(const Duration(seconds: 3), ()=>Navigator.popAndPushNamed(context,Routes.loginPage));
}

}

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
       Fluttertoast.showToast(
            msg: "User signed in with email: $email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      Logger().i("User signed in with email: ${userCredential.user}");
      return true;
    } catch (e) {
      Fluttertoast.showToast(
            msg:"Error signing in: $e",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.redAccent,
            fontSize: 16.0);
      Logger().e("Error signing in: $e");
      return false;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      if(context.mounted){
        Navigator.popAndPushNamed(context, Routes.loginPage);
      }
      Logger().i("User signed out");
    } catch (e) {
      Logger().e("Error signing out: $e");
      rethrow;
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

       await databaseRef.doc(_firebaseAuth.currentUser?.email).set({
        "name":"",
      "email": _firebaseAuth.currentUser?.email,
      "phone":""
      // Add other fields as necessary
    });
      Fluttertoast.showToast(
            msg: "User signed up with email: $email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
       Logger().i("User signed up with email: ${userCredential.user}");
      return true;
    } catch (e) {
       Fluttertoast.showToast(
            msg:"Error signing up: $e",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.redAccent,
            fontSize: 16.0);
      Logger().e("Error signing up: $e");
      return false;
    }
  }


}
