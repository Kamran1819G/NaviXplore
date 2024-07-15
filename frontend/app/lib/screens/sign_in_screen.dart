import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:navixplore/screens/sign_up_screen.dart';
import 'package:navixplore/utils/snackbar_util.dart';
import 'package:navixplore/widget_tree.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  Timer? _debounce;

  bool _isPasswordVisible = false;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  void _validateEmailDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isEmailValid = _isValidEmail(value);
      });
    });
  }

  Future<void> _handleSignInWithProvider(Future<void> Function() signUpMethod, String providerName) async {
    try {
      showCustomSnackBar(context, 'Signing in with $providerName...', Colors.orange);

      // Execute the provided sign-up method (Google or Apple)
      await signUpMethod();

      // Display success message
      showCustomSnackBar(context, 'Signed in with $providerName successfully!', Colors.green);

      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WidgetTree(), // Replace with your desired home screen
        ),
      );
    } catch (e) {
      // Display error message if sign-up fails
      showCustomSnackBar(context, e.toString(), Colors.red);
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    await _handleSignInWithProvider(() => FirebaseAuthService().signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ), 'Email and Password');
  }

  Future<void> signInWithGoogle() async {
    await _handleSignInWithProvider(() => FirebaseAuthService().signInWithGoogle(context), 'Google');
  }

  Future<void> signInWithApple() async {
    await _handleSignInWithProvider(() => FirebaseAuthService().signInWithApple(context), 'Apple');
  }



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
                          await FirebaseAuthService().signInAnonymously();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                          showCustomSnackBar(context, 'Signed in Anonymously', Colors.green);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: Colors.orange,
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
                            color: Colors.orange,
                            fontSize: 60,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("X",
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 75,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                    Text("plore",
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 60,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("Navi Mumbai Guide App",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: _emailController.text.isNotEmpty
                          ? _isEmailValid
                          ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                          : Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 'Invalid email address',
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      )
                          : null,
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
                      _validateEmailDebounced(value);
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
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
                          FirebaseAuthService().sendPasswordResetEmail(email: _emailController.text);
                          showCustomSnackBar(context, 'Password Reset Email Sent', Colors.orange);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Colors.orange,
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
                  onPressed: signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.orange,
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
                        color: Colors.orange,
                        fontSize: 16,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: signInWithGoogle,
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
                      onTap: signInWithApple,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Colors.orange,
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
