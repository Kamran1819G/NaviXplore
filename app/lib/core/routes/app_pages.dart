import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/features/auth/screen/forgot_password_screen.dart';
import 'package:navixplore/features/auth/screen/sign_in_screen.dart';
import 'package:navixplore/features/auth/screen/sign_up_screen.dart';
import 'package:navixplore/features/auth/screen/user_registration_screen.dart';
import 'package:navixplore/features/auth_gate.dart';
import 'package:navixplore/features/drawer/screen/terms_and_conditions_screen.dart';
import 'package:navixplore/features/explore/screen/explore_screen.dart';
import 'package:navixplore/features/main_screen.dart';
import 'package:navixplore/features/splash_screen.dart';
import 'package:navixplore/features/xplorefeed/screen/xplorefeed_screen.dart';

class AppPages {
  static final _signInScreen = SignInScreen();
  static final _signUpScreen = SignUpScreen();
  static final _forgotPasswordScreen = ForgotPasswordScreen();
  static const _homeScreen = MainScreen();
  static const _exploreScreen = ExploreScreen();
  static const _xploreFeedScreen = XploreFeedScreen();
  static const _splashScreen = SplashScreen();
  static const _authGate = AuthGate();
  static final _userRegistrationScreen = UserRegistrationScreen();
  static final _termsAndConditionsScreen = TermsAndConditionsScreen();

  static final pages = [
    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => _signInScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.SIGN_UP,
      page: () => _signUpScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => _forgotPasswordScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => _homeScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.EXPLORE,
      page: () => _exploreScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.XPLOREFEED,
      page: () => _xploreFeedScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => _splashScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.AUTH_GATE,
      page: () => _authGate,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.USER_REGISTRATION,
      page: () => _userRegistrationScreen,
      preventDuplicates: true,
    ),
    GetPage(
      name: AppRoutes.TERMS_AND_CONDITIONS,
      page: () => _termsAndConditionsScreen,
      preventDuplicates: true,
    ),
  ];
}
