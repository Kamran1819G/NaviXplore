import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// Custom Exception Class
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() {
    return 'AuthServiceException: $message';
  }
}


class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final isEmailValid = false.obs;
  final redColor = Colors.red;
  final greenColor = Colors.green;
  final _debounce = Debouncer(milliseconds: 500);


  void validateEmail(String email) {
    _debounce.run(() {
      isEmailValid.value = GetUtils.isEmail(email);
    });

  }

  void _showSnackBar(String title, String message, Color color){
    Get.snackbar(title, message, colorText: Colors.white, backgroundColor: color);
  }

  Future<void> sendPasswordResetEmail() async {
    if (!isEmailValid.value) {
      _showSnackBar('Error', 'Please enter a valid email', redColor);
      return;
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      _showSnackBar('Success', 'Password reset email sent', greenColor);
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error', e.message ?? 'An error occurred', redColor);
    } catch (e) {
      _showSnackBar('Error', e.toString(), redColor);
    } finally {
      isLoading.value = false;
    }
  }
}
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}