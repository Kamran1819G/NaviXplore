import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await Supabase.instance.client.auth.signInAnonymously();
      isLoading.value = false;
      return response.user;
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
      final response = await Supabase.instance.client.auth.signInWithPassword(
          email: emailController.text, password: passwordController.text);
      isLoading.value = false;
      return response.user;
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
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );
      if (response.user == null) {
        Get.snackbar('Error', 'Failed to sign in with Google',
            colorText: Colors.white, backgroundColor: Colors.red);
        return null;
      }
      isLoading.value = false;
      return response.user;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    isLoading.value = true;
    try {
      final rawNonce = Supabase.instance.client.auth.generateRawNonce();
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: rawNonce,
      );
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        nonce: rawNonce,
      );
      if (response.user == null) {
        Get.snackbar('Error', 'Failed to sign in with Apple',
            colorText: Colors.white, backgroundColor: Colors.red);
        return null;
      }
      isLoading.value = false;
      return response.user;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
      return null;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    isLoading.value = true;

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        emailController.text,
        redirectTo: 'io.supabase.navixplore://reset-password',
      );
      isLoading.value = false;
      Get.snackbar('Success', 'Password reset email sent',
          colorText: Colors.white, backgroundColor: Colors.green);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }
}
