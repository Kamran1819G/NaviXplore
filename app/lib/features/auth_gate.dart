import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/auth/controller/auth_controller.dart';
import 'package:navixplore/features/auth/screen/sign_in_screen.dart';
import 'package:navixplore/features/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Obx(() {
      return authController.isAuthenticated.value
          ? MainScreen()
          : SignInScreen();
    });
  }
}
