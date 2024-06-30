import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/controller/network_controller.dart';
import 'package:navixplore/screens/splash_screen.dart';
import 'package:navixplore/services/firebase/firebase_messaging_service.dart';
import 'package:navixplore/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.initialize();
  if (kDebugMode) {
    print('Firebase Messaging Service initialized : ${messagingService.getFCMToken()}');
  }


  // Initialize GetX controller
  Get.put<NetworkController>(NetworkController(), permanent: true);

  // Run the app
  runApp(const MyApp());
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

