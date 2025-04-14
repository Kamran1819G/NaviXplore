import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:navixplore/main.dart'; // Import your main.dart file
import 'package:navixplore/core/routes/app_routes.dart'; // Import your AppRoutes
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() {
  group('MyApp Widget Tests', () {
    // Set up SharedPreferences mock before running any tests in this group
    setUpAll(() async {
      SharedPreferences.setMockInitialValues(
          {}); // Set up default values for shared preferences
    });

    testWidgets(
        'Initial route is OnboardingScreen when onboarding is not completed',
        (WidgetTester tester) async {
      // Arrange: Set onboardingCompleted to false (or not set) in SharedPreferences mock
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onBoardingCompleted'); // Ensure it's not set

      // Act: Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp(
          onboardingCompleted:
              false)); // Pass onboardingCompleted = false for testing

      // Wait for the frame to settle (important for GetX navigation to complete)
      await tester.pumpAndSettle();

      // Assert: Check if the initial route is the onboarding screen route
      expect(Get.currentRoute, AppRoutes.ONBOARDING,
          reason: 'Initial route should be OnboardingScreen');
    });

    testWidgets('Initial route is AuthGate when onboarding is completed',
        (WidgetTester tester) async {
      // Arrange: Set onboardingCompleted to true in SharedPreferences mock
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onBoardingCompleted', true);

      // Act: Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp(
          onboardingCompleted:
              true)); // Pass onboardingCompleted = true for testing

      // Wait for the frame to settle (important for GetX navigation to complete)
      await tester.pumpAndSettle();

      // Assert: Check if the initial route is the AuthGate route
      expect(Get.currentRoute, AppRoutes.AUTH_GATE,
          reason: 'Initial route should be AuthGate');
    });

    // You can add more widget tests here, for example:
    // - Test if SignInScreen is displayed when AuthGate is the initial route and user is not authenticated (if you have SignInScreen widget tests)
    // - Test if MainScreen is displayed when AuthGate is the initial route and user is authenticated (if you have MainScreen widget tests)
  });
}
