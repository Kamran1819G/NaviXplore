import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/pages/auth/forgot_password_screen.dart';
import 'package:navixplore/presentation/pages/auth/sign_in_screen.dart';
import 'package:navixplore/presentation/pages/auth/sign_up_screen.dart';
import 'package:navixplore/presentation/pages/auth/user_registration_screen.dart';
import 'package:navixplore/presentation/pages/auth_gate.dart';
import 'package:navixplore/presentation/pages/drawer/terms_and_conditions_screen.dart';
import 'package:navixplore/presentation/pages/explore/explore_screen.dart';
import 'package:navixplore/presentation/pages/home_screen.dart';
import 'package:navixplore/presentation/pages/splash_screen.dart';
import 'package:navixplore/presentation/pages/transports/nmmt_bus/nmmt_bus_route_page.dart';
import 'package:navixplore/presentation/pages/xplorefeed/xplorefeed_screen.dart';

class AppPages {
  static final _signInScreen = SignInScreen();
  static final _signUpScreen = SignUpScreen();
  static final _forgotPasswordScreen = ForgotPasswordScreen();
  static const _homeScreen = HomeScreen();
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
    GetPage(
      name: AppRoutes.NMMT_BUS_ROUTE,
      page: () => NMMTBusRoutePage(
        routeid: int.parse(Get.parameters['routeId']!),
        busName: Get.parameters['busName']!,
        busTripId: Get.parameters['busTripId'],
        busArrivalTime: Get.parameters['busArrivalTime'],
      ),
    ),
  ];
}
