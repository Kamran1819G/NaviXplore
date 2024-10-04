import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/sign_up_controller.dart';
import 'package:navixplore/presentation/pages/auth/user_registration_screen.dart';

class SignUpScreen extends StatelessWidget {
  final SignUpController controller = Get.put(SignUpController());

  SignUpScreen({Key? key}) : super(key: key);

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
                SizedBox(height: 100.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Navi",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 60.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "X",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 75.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "plore",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 60.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Navi Mumbai Guide App",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 28.sp,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: controller.emailController.text.isNotEmpty
                              ? Obx(() => controller.isEmailValid.value
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : Icon(Icons.error, color: Colors.red))
                              : null,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          controller.validateEmail(value);
                        },
                      ),
                      SizedBox(height: 20.h),
                      TextField(
                        controller: controller.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextField(
                        controller: controller.confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final user = await controller.signUp();
                            if (user != null) {
                              Get.offNamed(AppRoutes.USER_REGISTRATION);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 75.h),
                Text(
                  'Or Sign Up With',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.sp,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final user = await controller.signInWithGoogle();
                        if (user != null) {
                          Get.offNamed(AppRoutes.USER_REGISTRATION);
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
                        final user = await controller.signInWithGoogle();
                        if (user != null) {
                          Get.offNamed(AppRoutes.USER_REGISTRATION);
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
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.SIGN_IN);
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16.sp,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                        ),
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
