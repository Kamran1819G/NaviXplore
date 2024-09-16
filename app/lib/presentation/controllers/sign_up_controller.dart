import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isEmailValid = false.obs;
  final isLoading = false.obs;

  void validateEmail(String email) {
    isEmailValid.value = GetUtils.isEmail(email);
  }

  Future<User?> signUp() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email',
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match',
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
    isLoading.value = true;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      isLoading.value = false;
      return credential.user;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak.',
            colorText: Colors.white, backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'The account already exists for that email.',
            colorText: Colors.white, backgroundColor: Colors.red);
      } else {
        Get.snackbar('Error', e.message ?? 'An error occurred',
            colorText: Colors.white, backgroundColor: Colors.red);
      }
      return null;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
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
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
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