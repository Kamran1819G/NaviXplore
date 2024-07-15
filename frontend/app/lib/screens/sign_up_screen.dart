import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navixplore/screens/user_registration_screen.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/screens/sign_in_screen.dart';
import 'package:navixplore/utils/color_utils.dart';
import 'package:navixplore/utils/snackbar_util.dart';
import 'package:navixplore/widget_tree.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _confirmPasswordVisible = false;
  bool _showPasswordStrength = false;
  double _passwordStrength = 0;
  bool _passwordsMatch = false;
  bool _isEmailValid = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    _passwordFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_passwordFocusNode.hasFocus) {
      setState(() {
        _showPasswordStrength = false;
      });
    }
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

  double _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength;
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength <= 0.3) return Colors.red;
    if (_passwordStrength <= 0.6) return Colors.orange;
    return Colors.green;
  }

  Future<void> _handleSignUpWithProvider(
      Future<User?> Function() signUpMethod, String providerName) async {
    try {
      showCustomSnackBar(
          context, 'Signing up with $providerName...', Colors.orange);

      // Execute the provided sign-up method (Google, Apple, or Email/Password)
      User? user = await signUpMethod();

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Store verification status in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'emailVerified': false,
          'signUpMethod': providerName,
        }, SetOptions(merge: true));

        showCustomSnackBar(context,
            'Signed up with $providerName successfully!', Colors.green);

        // Navigate to user registration screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserRegistrationScreen(user: user),
          ),
        );
      }
    } catch (e) {
      showCustomSnackBar(context, e.toString(), Colors.red);
    }
  }

  Future<void> signUpWithEmailAndPassword() async {
    await _handleSignUpWithProvider(
        () => FirebaseAuthService().signUpWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            ),
        'Email and Password');
  }

  Future<void> signUpWithGoogle() async {
    await _handleSignUpWithProvider(
        () => FirebaseAuthService().signUpWithGoogle(), 'Google');
  }

  Future<void> signUpWithApple() async {
    await _handleSignUpWithProvider(
        () => FirebaseAuthService().signUpWithApple(), 'Apple');
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Navi",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 60,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "X",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 75,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "plore",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 60,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Navi Mumbai Guide App",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 28,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          _validateEmailDebounced(value);
                        },
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _passwordController.text.isNotEmpty &&
                                  _passwordController.text.length < 8
                              ? 'Password must be at least 8 characters long'
                              : null,
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
                          setState(() {
                            _showPasswordStrength = true;
                            _passwordStrength = _calculatePasswordStrength(value);
                          });
                        },
                      ),
                      if (_showPasswordStrength)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 5, right: 10, left: 10),
                          child: LinearProgressIndicator(
                            value: _passwordStrength,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(10),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getPasswordStrengthColor()),
                          ),
                        ),
                      SizedBox(height: 20),
                      TextField(
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !_confirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_confirmPasswordController.text.isNotEmpty)
                                  _passwordsMatch
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : Tooltip(
                                          triggerMode: TooltipTriggerMode.tap,
                                          message: 'Passwords do not match',
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                IconButton(
                                    icon: Icon(_confirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    }),
                              ],
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _passwordsMatch = _passwordController.text == value;
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await signUpWithEmailAndPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Text(
                  'Or Sign Up With',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: signUpWithGoogle,
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
                      onTap: signUpWithApple,
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
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
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
