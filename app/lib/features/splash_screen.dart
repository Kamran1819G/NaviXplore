import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuthGate();
  }

  _navigateToAuthGate() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    Get.offAllNamed(AppRoutes.AUTH_GATE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Navi",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold)),
                  Text("X",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 75,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold)),
                  Text("plore",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text("Navi Mumbai Guide App",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
