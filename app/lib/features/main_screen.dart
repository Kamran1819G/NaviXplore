import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/features/auth/controller/auth_controller.dart';
import 'package:navixplore/features/drawer/screen/report_issue_screen.dart';
import 'package:navixplore/features/drawer/screen/suggest_feature_screen.dart';
import 'package:navixplore/features/explore/screen/explore_screen.dart';
import 'package:navixplore/features/profile/screen/user_profile_screen.dart';
import 'package:navixplore/features/transports/transports_screen.dart';
import 'package:navixplore/features/xplorefeed/screen/xplorefeed_screen.dart';
import 'package:navixplore/features/widgets/webview_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // Import analytics
import 'package:share_plus/share_plus.dart'; // Import share_plus for sharing

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthController authController = Get.find<AuthController>();
  int _selectedIndex = 0;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static List<Widget> _widgetOptions = [
    TransportsScreen(),
    ExploreScreen(),
    XploreFeedScreen(),
    UserProfileScreen(
        userId: Get.find<AuthController>().currentUser!.uid, isMyProfile: true),
  ];

  // SOS Functionality - Moved to top for better readability
  Future<void> _launchSOSCall() async {
    const String emergencyNumber = '112'; // Standard emergency number, can be configurable
    final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      barrierDismissible: false,
      text: 'Do you want to call the emergency number?',
      confirmBtnText: 'Yes',
      confirmBtnColor: Colors.red,
      showCancelBtn: true,
      cancelBtnText: 'No',
      onConfirmBtnTap: () async {
        // Added try-catch for better error handling during phone call launch
        try {
          if (await canLaunchUrl(phoneUri)) { // Changed to canLaunchUrl and launchUrl
            await launchUrl(phoneUri); // Changed to launchUrl
            await analytics.logEvent(name: 'sos_call_initiated');
          } else {
            QuickAlert.show(
              context: context,
              title: 'Error',
              text: 'Could not launch the phone app.',
              type: QuickAlertType.error,
            );
          }
        } catch (e) {
          // More specific error message for launching phone call
          QuickAlert.show(
            context: context,
            title: 'Error',
            text: 'Error launching phone app: $e',
            type: QuickAlertType.error,
          );
          analytics.logEvent(name: 'sos_call_failed', parameters: {'error': e.toString()}); // Log failure
        }
      },
    );
  }

  // Share App Functionality
  Future<void> _shareApp() async {
    try {
      await Share.share(
          'Check out NaviXplore! [Your app link here - Replace this with actual link]', // Replace with actual app link
          subject: 'Share NaviXplore App');
      analytics.logEvent(name: 'share_app_initiated');
    } catch (e) {
      QuickAlert.show(
        context: context,
        title: 'Error',
        text: 'Could not share the app.',
        type: QuickAlertType.error,
      );
      analytics.logEvent(name: 'share_app_failed', parameters: {'error': e.toString()}); // Log failure
    }
  }

  // Support Functionality - Example: Contact Us via Email
  Future<void> _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@navixplore.com', // Replace with your support email
      queryParameters: {
        'subject': 'NaviXplore App Support Request',
        'body': 'Dear NaviXplore Support Team,\n\nI am writing to you regarding...\n',
      },
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) { // Changed to canLaunchUrl and launchUrl
        await launchUrl(emailLaunchUri); // Changed to launchUrl
        analytics.logEvent(name: 'support_email_initiated');
      } else {
        QuickAlert.show(
          context: context,
          title: 'Error',
          text: 'Could not open email app.',
          type: QuickAlertType.error,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        title: 'Error',
        text: 'Error opening email app: $e',
        type: QuickAlertType.error,
      );
      analytics.logEvent(name: 'support_email_failed', parameters: {'error': e.toString()}); // Log failure
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              // Consider using Image.asset for logo if it's an image file for better performance
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Navi",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 45.sp)),
                  Text("X",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 60.sp)),
                  Text("plore",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 45.sp)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stars),
              title: const Text("What's New?", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_whats_new_tapped');
                Get.to(
                      () => const WebView_Screen( // Added const here
                      url: 'https://navixplore.vercel.app/changelogs'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sos_rounded),
              title: const Text("SOS", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_sos_tapped');
                _launchSOSCall(); // Call SOS Function
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text("Suggest a Feature", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_suggest_feature_tapped');
                Get.to(() => const FeatureSuggestionScreen()); // Added const here
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text("Report an Issue", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_report_issue_tapped');
                Get.to(() => const ReportIssueScreen()); // Added const here
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share with Friends", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_share_friends_tapped');
                _shareApp(); // Call share app function
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.newspaper_rounded),
              title: const Text( // Added const here
                "Advertise with us",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                analytics.logEvent(name: 'drawer_advertise_tapped');
                Get.to(
                      () => const WebView_Screen( // Added const here
                      url: 'https://navixplore.vercel.app/advertise-with-us'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text("Support", // Added const here
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                analytics.logEvent(name: 'drawer_support_tapped');
                _contactSupport(); // Call support function
              },
            ),
            ListTile(
                leading: const Icon(Icons.note_alt),
                title: const Text("Term & Conditions", // Added const here
                    style: TextStyle(
                      fontSize: 16,
                    )),
                onTap: () {
                  analytics.logEvent(name: 'drawer_terms_tapped');
                  Get.toNamed(AppRoutes.TERMS_AND_CONDITIONS);
                }),
            if (authController.isAuthenticated.value == true)
              ListTile(
                leading:
                Icon(Icons.logout, color: Theme.of(context).primaryColor),
                title: Text("Sign Out",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () async {
                  analytics.logEvent(name: 'sign_out_tapped');
                  await authController.signOut();
                  authController.isAuthenticated.value = false;
                  Get.offAllNamed(AppRoutes.AUTH_GATE);
                },
              ),
            if (authController.isAuthenticated.value == false)
              ListTile(
                leading:
                Icon(Icons.login, color: Theme.of(context).primaryColor),
                title: Text("Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  analytics.logEvent(name: 'sign_up_tapped');
                  Get.offAllNamed(AppRoutes.SIGN_UP);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: GNav(
          backgroundColor: Colors.white,
          color: Colors.grey.shade700,
          activeColor: Colors.white,
          tabBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          iconSize: 24,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _logBottomNavTabChange(index);
          },
          // Added semantic labels for accessibility
          tabs: const [
            GButton(
              icon: Icons.emoji_transportation,
              text: "Transports",
              semanticLabel: 'Transports',
            ),
            GButton(
              icon: Icons.explore,
              text: "Xplore",
              semanticLabel: 'Explore',
            ),
            GButton(
              icon: Icons.dynamic_feed,
              text: "XploreFeed",
              semanticLabel: 'Xplore Feed',
            ),
            GButton(
              icon: Icons.person,
              text: "Profile",
              semanticLabel: 'Profile',
            )
          ],
        ),
      ),
    );
  }

  // Helper function to log tab changes - Kept as is, already well-structured
  Future<void> _logBottomNavTabChange(int index) async {
    String tabName = '';
    switch (index) {
      case 0:
        tabName = 'Transports';
        break;
      case 1:
        tabName = 'Explore';
        break;
      case 2:
        tabName = 'XploreFeed';
        break;
      case 3:
        tabName = 'Profile';
        break;
    }
    await analytics.logEvent(
        name: 'bottom_nav_tab_change', parameters: {'tab_name': tabName});
  }
}