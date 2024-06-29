import 'package:flutter/material.dart';
import 'package:navixplore/services/firebase_auth_service.dart';
import 'package:navixplore/screens/home_screen.dart';
import 'package:navixplore/screens/sign_in_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return SignInScreen();
      },
    );
  }
}
