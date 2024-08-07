import 'dart:io';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/user_registration_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreen extends StatelessWidget {
  UserRegistrationController controller = Get.put(UserRegistrationController());

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [],
        ),
      ),
    );
  }
}
