import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final isEmailValid = false.obs;

  void validateEmail(String email) {
    isEmailValid.value = GetUtils.isEmail(email);
  }

  Future<void> sendPasswordResetEmail() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      isLoading.value = false;
      Get.snackbar('Success', 'Password reset email sent',
          colorText: Colors.white, backgroundColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message ?? 'An error occurred',
          colorText: Colors.white, backgroundColor: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }
}