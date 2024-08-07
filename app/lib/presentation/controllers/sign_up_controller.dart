import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
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
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      isLoading.value = false;
      if (response) {
        // If sign in was successful, fetch the user
        final user = await Supabase.instance.client.auth.currentUser;
        return user;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
    return null;
  }

  Future<User?> signInWithApple() async {
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      isLoading.value = false;
      isLoading.value = false;
      if (response) {
        // If sign in was successful, fetch the user
        final user = await Supabase.instance.client.auth.currentUser;
        return user;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
    return null;
  }
}
