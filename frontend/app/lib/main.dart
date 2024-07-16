import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/controller/network_controller.dart';
import 'package:navixplore/screens/splash_screen.dart';
import 'package:navixplore/services/firebase/firebase_messaging_service.dart';
import 'package:navixplore/services/permission_handler_service.dart';
import 'package:navixplore/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PermissionHandlerService _permissionHandler = PermissionHandlerService();
  await _permissionHandler.requestMultiplePermissions();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lsovwpfxweicraibsgsy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxzb3Z3cGZ4d2VpY3JhaWJzZ3N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAxOTMwMjAsImV4cCI6MjAzNTc2OTAyMH0.NuZX8AqgAEM6SRLrHWHoW5Qdk6Bl-EZl9M60LM1nkcA',
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
      theme: ThemeData(
        primaryColor: Colors.purple.shade700,
        scaffoldBackgroundColor: Colors.white,
        hintColor: Theme.of(context).primaryColor,
      ),
      darkTheme: darkMode,
      home: const SplashScreen(),
    );
  }
}

