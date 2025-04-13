import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/features/auth/controller/auth_controller.dart';
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
    if (passwordController.text != confirmPasswordController.text) {
      Get.showSnackbar(const GetSnackBar(
        icon: Icon(
          Icons.error,
          color: Colors.white,
        ),
        message: 'Passwords do not match',
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
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      isLoading.value = false;
      return credential.user;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'weak-password') {
        Get.showSnackbar(const GetSnackBar(
          icon: Icon(
            Icons.error,
            color: Colors.white,
          ),
          title: 'Weak Password',
          message: 'The password provided is too weak.',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ));
      } else if (e.code == 'email-already-in-use') {
        Get.showSnackbar(
          const GetSnackBar(
            icon: Icon(
              Icons.error,
              color: Colors.white,
            ),
            title: 'Email Already In Use',
            message: 'The account already exists for that email.',
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            borderRadius: 8,
          ),
        );
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

  Future<User?> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
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
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
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
}
