import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/screens/sign_in_screen.dart';
import 'package:navixplore/widget_tree.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _addUserDetail() async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuthService().currentUser?.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
      });
    }catch(e){
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

  Future<void> _signUpWithEmailAndPassword() async {
    try {
      await FirebaseAuthService().signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _addUserDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signed up',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WidgetTree(),
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
              onPressed: _signUpWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.orange,
              ),
              child: Text(
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
            Text('Or Sign Up With',
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
                  onTap: () {},
                  child: Container(
                    height: 75,
                    width: 75,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.phone, size: 40),
                  ),
                ),
                SizedBox(width: 40),
                GestureDetector(
                  onTap: () async {

                  },
                  child: Container(
                    height: 75,
                    width: 75,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person, size: 40),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
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
                        builder: (context) => SignInScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign In",
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
