import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navixplore/core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages =
      2; // Number of onboarding screens (adjust if you add more)

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0.w),
      height: 8.0.h,
      width: isActive ? 24.0.w : 16.0.w,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: <Widget>[
                  _buildOnboardingPage(
                    image:
                        'assets/onboarding_image1.png', // Replace with your first onboarding image asset path
                    title: 'Find Hidden Gems', // Title for the first screen
                    description:
                        'Discover top-rated food, attractions & events.', // Description for the first screen
                  ),
                  _buildOnboardingPage(
                    image:
                        'assets/onboarding_image2.png', // Replace with your second onboarding image asset path
                    title: 'Talk Like a Local', // Title for the second screen
                    description:
                        'Built-in translator for effortless communication.', // Description for the second screen
                  ),
                  // Add more _buildOnboardingPage widgets for additional screens if needed
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 24.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DotsIndicator(
                    // Using dots_indicator package for page dots
                    dotsCount: _numPages,
                    position: _currentPage.toDouble(),
                    decorator: DotsDecorator(
                      color: Colors.grey, // Inactive dot color
                      activeColor: Theme.of(context).primaryColor,
                      size: Size(8.0.w, 8.0.h),
                      activeSize: Size(24.0.w, 8.0.h),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0.r)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == _numPages - 1) {
                        // On the last page, mark onboarding as completed and navigate to your main app
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('onBoardingCompleted',
                            true); // Use the same key as in main.dart

                        Get.offAllNamed(AppRoutes
                            .AUTH_GATE); // Navigate to your AuthGate or Home screen route
                      } else {
                        // Go to the next page if not on the last page
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0.r)), // Rounded button
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0.w,
                          vertical: 10.0.h), // Button padding
                    ),
                    child: Text(
                      _currentPage == _numPages - 1
                          ? 'Get Started'
                          : 'Skip', // Button text changes on last page
                      style: const TextStyle(
                          color: Colors.white), // Button text color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
      {required String image,
      required String title,
      required String description}) {
    return Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            image, // Image asset path passed as argument
            height: 300.0.h, // Image height, adjust as needed
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30.0.h),
          Container(
            padding: EdgeInsets.only(right: 50.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, // Title text passed as argument
                  style: TextStyle(
                    fontSize:
                        24.0.sp, // Title font size, responsive with ScreenUtil
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0.h),
                Text(
                  description, // Description text passed as argument
                  style: TextStyle(
                    fontSize: 16.0
                        .sp, // Description font size, responsive with ScreenUtil
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600], // Description text color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
