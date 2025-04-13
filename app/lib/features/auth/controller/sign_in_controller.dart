import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/features/auth/controller/auth_controller.dart';

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
      Get.showSnackbar(
        GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
      return null;
    }
  }

  Future<User?> signIn() async {
    if (!isEmailValid.value) {
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.error,
          color: Colors.white,
        ),
        message: 'Please enter a valid email',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        borderRadius: 8,
      ));
      return null;
    }

    if (!isPasswordValid.value) {
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.error,
          color: Colors.white,
        ),
        message: 'Please enter a valid password',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        borderRadius: 8,
      ));
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
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        message: 'Signed in successfully',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        borderRadius: 8,
      ));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'user-not-found') {
        Get.showSnackbar(const GetSnackBar(
          icon: Icon(
            Icons.error,
            color: Colors.white,
          ),
          title: 'User Not Found',
          message: 'No user found for that email.',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ));
      } else if (e.code == 'wrong-password') {
        Get.showSnackbar(const GetSnackBar(
          icon: Icon(
            Icons.error,
            color: Colors.white,
          ),
          title: 'Wrong Password',
          message: 'Wrong password provided for that user.',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ));
      } else {
        Get.showSnackbar(
          GetSnackBar(
            icon: const Icon(
              Icons.error,
              color: Colors.white,
            ),
            title: e.code,
            message: e.message ?? 'An error occurred',
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            borderRadius: 8,
          ),
        );
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
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        message: 'Signed in successfully',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        borderRadius: 8,
      ));
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.showSnackbar(
        GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
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
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        message: 'Signed in successfully',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        borderRadius: 8,
      ));
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.showSnackbar(
        GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
      return null;
    }
  }
}
