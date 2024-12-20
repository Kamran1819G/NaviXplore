import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/auth_controller.dart';
import 'package:navixplore/presentation/pages/drawer/report_issue_screen.dart';
import 'package:navixplore/presentation/pages/drawer/suggest_feature_screen.dart';
import 'package:navixplore/presentation/pages/explore/explore_screen.dart';
import 'package:navixplore/presentation/pages/profile/user_profile_screen.dart';
import 'package:navixplore/presentation/pages/transports/transports_screen.dart';
import 'package:navixplore/presentation/pages/xplorefeed/xplorefeed_screen.dart';
import 'package:navixplore/presentation/widgets/webview_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [
    const TransportsScreen(),
    const ExploreScreen(),
    const XploreFeedScreen(),
    UserProfileScreen(
        userId: Get.find<AuthController>().currentUser!.uid, isMyProfile: true),
  ];

  // New SOS Functionality
  Future<void> _launchSOSCall() async {
    // Replace with the actual SOS number you want to dial
    const String emergencyNumber = '112'; // Or a specific contact
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
        if (await canLaunch(phoneUri.toString())) {
          await launch(phoneUri.toString());
        } else {
          QuickAlert.show(
            context: context,
            title: 'Error',
            text: 'Could not launch the phone app.',
            type: QuickAlertType.error,
          );
        }
      },
    );
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
              title: Text("What's New?",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                Get.to(
                  () => const WebView_Screen(
                      url: 'https://navixplore.vercel.app/changelogs'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sos_rounded),
              title: Text("SOS",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: _launchSOSCall, // Call SOS Function
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text("Suggest a Feature",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                Get.to(() => const FeatureSuggestionScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text("Report an Issue",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () {
                Get.to(() => const ReportIssueScreen());
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share with Friends",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.newspaper_rounded),
              title: const Text(
                "Advertise with us",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Get.to(
                  () => const WebView_Screen(
                      url: 'https://navixplore.vercel.app/advertise-with-us'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text("Support",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            ListTile(
                leading: const Icon(Icons.note_alt),
                title: const Text("Term & Conditions",
                    style: TextStyle(
                      fontSize: 16,
                    )),
                onTap: () {
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
          },
          tabs: const [
            GButton(
              icon: Icons.emoji_transportation,
              text: "Transports",
            ),
            GButton(
              icon: Icons.explore,
              text: "Explore",
            ),
            GButton(
              icon: Icons.dynamic_feed,
              text: "XploreFeed",
            ),
            GButton(
              icon: Icons.person,
              text: "Profile",
            )
          ],
        ),
      ),
    );
  }
}
