import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/pages/auth/sign_in_screen.dart';
import 'package:navixplore/presentation/pages/auth/sign_up_screen.dart';
import 'package:navixplore/presentation/pages/auth/user_registration_screen.dart';
import 'package:navixplore/presentation/pages/drawer/terms_and_conditions_screen.dart';
import 'package:navixplore/presentation/pages/splash_screen.dart';
import 'package:navixplore/presentation/pages/auth_gate.dart';
import 'package:navixplore/presentation/pages/home_screen.dart';
import 'package:navixplore/presentation/pages/explore/explore_screen.dart';
import 'package:navixplore/presentation/pages/xplorefeed/xplorefeed_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.SIGN_IN, page: () => SignInScreen()),
    GetPage(name: AppRoutes.SIGN_UP, page: () => SignUpScreen()),
    GetPage(name: AppRoutes.HOME, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.EXPLORE, page: () => const ExploreScreen()),
    GetPage(name: AppRoutes.XPLOREFEED, page: () => const XploreFeedScreen()),
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.AUTH_GATE, page: () => const AuthGate()),
    GetPage(
        name: AppRoutes.USER_REGISTRATION,
        page: () => UserRegistrationScreen()),
    GetPage(
        name: AppRoutes.TERMS_AND_CONDITIONS,
        page: () => TermsAndConditionsScreen()),
  ];
}
