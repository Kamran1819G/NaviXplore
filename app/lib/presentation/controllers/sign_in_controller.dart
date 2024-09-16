import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;

  void validateEmail(String email) {
    isEmailValid.value = GetUtils.isEmail(email);
  }

  void validatePassword(String password) {
    isPasswordValid.value = password.length >= 6;
  }

  Future<User?> signInAnonymously() async {
    isLoading.value = true;
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      isLoading.value = false;
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }

  Future<User?> signIn() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email',
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }

    if (!isPasswordValid.value) {
      Get.snackbar('Error', 'Please enter a valid password',
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }

    isLoading.value = true;

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      isLoading.value = false;
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'No user found for that email.',
            colorText: Colors.white, backgroundColor: Colors.red);
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Wrong password provided for that user.',
            colorText: Colors.white, backgroundColor: Colors.red);
      } else {
        Get.snackbar('Error', e.message ?? 'An error occurred',
            colorText: Colors.white, backgroundColor: Colors.red);
      }
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.snackbar('Error', 'Failed to sign in with Google',
            colorText: Colors.white, backgroundColor: Colors.red);
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      isLoading.value = false;
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    isLoading.value = true;
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('fullName');

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(appleProvider);
      isLoading.value = false;
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }
}
