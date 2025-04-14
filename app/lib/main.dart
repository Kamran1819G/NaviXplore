import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:navixplore/core/routes/app_pages.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/core/controllers/network_controller.dart';
import 'package:navixplore/core/controllers/notification_controller.dart';
import 'package:navixplore/core/controllers/permission_controller.dart';
import 'package:navixplore/core/theme/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool onboardingCompleted = prefs.getBool('onBoardingCompleted') ?? false;

  // Load environment variables
  // await dotenv.load(fileName: ".env.dev");

  final PermissionController permissionController =
      Get.put(PermissionController());

  await permissionController.requestPermissions();

  Get.put<NetworkController>(NetworkController(), permanent: true);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await NotificationController.initialize();

  await GetStorage.init();

  // Run the app
  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      enableScaleText: () => false,
      enableScaleWH: () => false,
      builder: (_, child) => GetMaterialApp(
        themeMode: ThemeMode.light,
        theme: lightMode,
        darkTheme: darkMode,
        initialRoute:
            onboardingCompleted ? AppRoutes.SPLASH : AppRoutes.ONBOARDING,
        getPages: AppPages.pages,
      ),
    );
  }
}
