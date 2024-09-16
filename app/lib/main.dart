import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:navixplore/core/routes/app_pages.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/network_controller.dart';
import 'package:navixplore/presentation/controllers/notification_controller.dart';
import 'package:navixplore/presentation/controllers/permission_controller.dart';
import 'package:navixplore/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await NotificationController.initialize();

  await GetStorage.init();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      enableScaleText: () => false,
      enableScaleWH: () => false,
      builder: (_, child) => GetMaterialApp(
        themeMode: ThemeMode.light,
        theme: ThemeData(
          primaryColor: Colors.purple.shade700,
          scaffoldBackgroundColor: Colors.white,
          hintColor: Theme.of(context).primaryColor,
        ),
        darkTheme: darkMode,
        initialRoute: AppRoutes.SPLASH,
        getPages: AppPages.pages,
      ),
    );
  }
}
