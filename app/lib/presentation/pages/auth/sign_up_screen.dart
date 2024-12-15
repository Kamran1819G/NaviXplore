import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/sign_up_controller.dart';
import 'package:rxdart/rxdart.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController controller = Get.put(SignUpController());

  final _emailSubject = PublishSubject<String>();


  @override
  void initState() {
    super.initState();
    _setupInputListeners();
  }

  void _setupInputListeners() {
    _emailSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen(controller.validateEmail);
  }

  @override
  void dispose() {
    _emailSubject.close();
    super.dispose();
  }

  TextStyle get _textStyle => TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 16.sp,
      fontFamily: "Fredoka",
      fontWeight: FontWeight.bold);


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
                _buildTitle(),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Column(
                    children: [
                      _buildEmailTextField(),
                      Obx(() => controller.isEmailValid.value == false && controller.emailController.text.isNotEmpty
                          ?  Padding(
                        padding: EdgeInsets.only(left:25.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Invalid Email Address',
                            style: TextStyle(color: Colors.red,fontSize: 12.sp),
                          ),
                        ),
                      )
                          : const SizedBox.shrink()
                      ),
                      SizedBox(height: 10.h),
                      _buildPasswordTextField(),
                      SizedBox(height: 20.h),
                      _buildConfirmPasswordTextField(),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                _buildSignUpButton(context),
                SizedBox(height: 75.h),
                Text(
                  'Or Sign Up With',
                  style: _textStyle,
                ),
                SizedBox(height: 20.h),
                _buildSocialSignUpButtons(),
                SizedBox(height: 20.h),
                _buildSignInPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTitle() {
    return Row(
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
    );
  }

  Widget _buildEmailTextField() {
    return  TextField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(color: Colors.white),
        ),
        suffixIcon: controller.emailController.text.isNotEmpty
            ? Obx(() => controller.isEmailValid.value
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.error, color: Colors.red))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      onChanged: (value) => _emailSubject.add(value),
    );
  }


  Widget _buildPasswordTextField() {
    return TextField(
      controller: controller.passwordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: const BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextField(
      controller: controller.confirmPasswordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: const BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return  Obx(
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
          padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
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
    );
  }

  Widget _buildSocialSignUpButtons() {
    return Row(
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
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
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
            style: _textStyle,
          ),
        ),
      ],
    );
  }
}