import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreen extends StatefulWidget {
  final User user;

  const UserRegistrationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  File? _image;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  PageController _pageController = PageController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Stack(),
            Container(
              color: Colors.green,
              child: Center(
                child: Text('User Registration Screen 2'),
              ),
            ),
            Container(
              color: Colors.blue,
              child: Center(
                child: Text('User Registration Screen 3'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
