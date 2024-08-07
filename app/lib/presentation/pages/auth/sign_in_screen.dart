import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/sign_in_controller.dart';
import 'package:navixplore/presentation/pages/auth/sign_up_screen.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key}) : super(key: key);

  final SignInController controller = Get.put(SignInController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          await controller.signInAnonymously();
                          Get.offAllNamed(AppRoutes.AUTH_GATE);
                          Get.snackbar('Success', 'Signed in Anonymously',
                              colorText: Colors.white,
                              backgroundColor: Colors.green);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "Guest",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Navi",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 60,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("X",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 75,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("plore",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 60,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("Navi Mumbai Guide App",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 28,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: Obx(() => controller.isEmailValid.value
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.error, color: Colors.red)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      controller.validateEmail(value);
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: controller.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      controller.validatePassword(value);
                    },
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          controller.sendPasswordResetEmail();
                          Get.snackbar('Password Reset',
                              'Password reset email sent successfully',
                              colorText: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontFamily: "Fredoka",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await controller.signIn();
                      Get.offAllNamed(AppRoutes.AUTH_GATE);
                      Get.snackbar('Success', 'Signed in successfully',
                          colorText: Colors.white,
                          backgroundColor: Colors.green);
                    } catch (e) {
                      Get.snackbar('Error', e.toString(),
                          colorText: Colors.white, backgroundColor: Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Text('Or Sign In With',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await controller.signInWithGoogle();
                        if (authController.isAuthenticated.value) {
                          Get.offAllNamed(AppRoutes.AUTH_GATE);
                        }
                      },
                      child: Container(
                        height: 75,
                        width: 75,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset('assets/icons/google.png'),
                      ),
                    ),
                    SizedBox(width: 40),
                    GestureDetector(
                      onTap: () async {
                        await controller.signInWithApple();
                        if (authController.isAuthenticated.value) {
                          Get.offAllNamed(AppRoutes.AUTH_GATE);
                          Get.snackbar('Success', 'Signed in with Apple',
                              colorText: Colors.white,
                              backgroundColor: Colors.green);
                        }
                      },
                      child: Container(
                        height: 75,
                        width: 75,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset('assets/icons/apple.png'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.SIGN_UP);
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
