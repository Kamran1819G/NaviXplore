import 'package:flutter/material.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:navixplore/screens/sign_up_screen.dart';

import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuthService().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sign In Successful',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await FirebaseAuthService().signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sign In Successful',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithApple() async {
    try {
      await FirebaseAuthService().signInWithApple();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Apple Sign In Successful',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children:[
                  Spacer(),
                  TextButton(
                    onPressed: () async{
                      await FirebaseAuthService().signInAnonymously();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Signed in Anonymously',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
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
                          fontWeight: FontWeight.bold),
                    )
                  )
                ]
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
                controller: emailController,
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
                controller: passwordController,
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
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: (){
                      FirebaseAuthService().sendPasswordResetEmail(email: emailController.text);
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
    );
  }
}
