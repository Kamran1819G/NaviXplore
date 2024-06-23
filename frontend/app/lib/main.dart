import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/dependency_injection.dart';
import 'package:navixplore/screens/splash_screen.dart';
import 'package:navixplore/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  print('FCM Token: $fcmToken');
  runApp(const MyApp());
  DependencyInjection.init();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      theme: lightMode,
      darkTheme: darkMode,
      home: const SplashScreen(),
    );
  }
}

