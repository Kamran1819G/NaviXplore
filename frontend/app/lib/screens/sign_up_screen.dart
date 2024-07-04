import 'package:flutter/material.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/screens/sign_in_screen.dart';
import 'package:navixplore/utils/snackbar_util.dart';
import 'package:navixplore/widget_tree.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _addUserDetail(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
      });
    } catch (e) {
      showCustomSnackBar(context, e.toString(), Colors.red);
    }
  }


  Future<void> _handleSignUpWithProvider(Future<void> Function() signUpMethod, String providerName) async {
    try {
      showCustomSnackBar(context, 'Signing up with $providerName...', Colors.orange);

      // Execute the provided sign-up method (Google or Apple)
      await signUpMethod();

      // Display success message
      showCustomSnackBar(context, 'Signed up with $providerName successfully!', Colors.green);

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


  Future<void> signUpWithEmailAndPassword() async {
    await _handleSignUpWithProvider(() => FirebaseAuthService().signUpWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
    ), 'Email and Password');
  }

  Future<void> signUpWithGoogle() async {
    await _handleSignUpWithProvider(() => FirebaseAuthService().signUpWithGoogle(), 'Google');
  }

  Future<void> signUpWithApple() async {
    await _handleSignUpWithProvider(() => FirebaseAuthService().signUpWithApple(), 'Apple');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
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
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
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
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
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
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: signUpWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
    );
  }
}
