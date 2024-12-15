import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:navixplore/presentation/pages/auth/sign_in_screen.dart';
import 'package:navixplore/presentation/pages/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Obx(() {
      return authController.isAuthenticated.value
          ? HomeScreen()
          : SignInScreen();
    });
  }
}
