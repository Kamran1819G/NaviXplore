import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                              horizontal: 30.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "Guest",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Navi",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 60.sp,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("X",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 75.sp,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("plore",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 60.sp,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("Navi Mumbai Guide App",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 28.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: controller.emailController.text.isNotEmpty
                          ? Obx(() => controller.isEmailValid.value
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.error, color: Colors.red))
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      controller.validateEmail(value);
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: TextField(
                    controller: controller.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      controller.validatePassword(value);
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.FORGOT_PASSWORD);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.sp,
                              fontFamily: "Fredoka",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await controller.signIn();
                      Get.offAllNamed(AppRoutes.AUTH_GATE);
                    } catch (e) {
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
                          margin: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          borderRadius: 8,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 75.h),
                Text('Or Sign In With',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
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
                        height: 75.h,
                        width: 75.w,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Image.asset('assets/icons/google.png'),
                      ),
                    ),
                    SizedBox(width: 30.w),
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
                        height: 75.h,
                        width: 75.w,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Image.asset('assets/icons/apple.png'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                          fontSize: 16.sp,
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
                            fontSize: 16.sp,
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
