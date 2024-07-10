import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:navixplore/screens/profile_screen.dart';
import 'package:navixplore/screens/sign_up_screen.dart';
import 'package:navixplore/services/firebase/firebase_auth_service.dart';
import 'package:navixplore/screens/explore_screen.dart';
import 'package:navixplore/screens/news_screen.dart';
import 'package:navixplore/screens/sign_in_screen.dart';
import 'package:navixplore/screens/transports_screen.dart';
import 'package:navixplore/screens/suggest_feature_screen.dart';
import 'package:navixplore/screens/report_issue_screen.dart';
import 'package:navixplore/utils/color_utils.dart';
import 'package:navixplore/widgets/webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const TransportsScreen(),
    const ExploreScreen(),
    const NewsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('#F5F5F5'),
      // Header
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        elevation: 3,
        title: const Row(
          children: [
            Text("Navi",
                style: TextStyle(
                    color: Colors.orange,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text("X",
                style: TextStyle(
                    color: Colors.orange,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
            Text("plore",
                style: TextStyle(
                    color: Colors.orange,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.orange),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // notification icon
          IconButton(
            icon: const Icon(CupertinoIcons.cube_box_fill, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),

      // Main body
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // Side Menu
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Navi",
                        style: TextStyle(
                            color: Colors.orange,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                            fontSize: 45)),
                    Text("X",
                        style: TextStyle(
                            color: Colors.orange,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                            fontSize: 60)),
                    Text("plore",
                        style: TextStyle(
                            color: Colors.orange,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                            fontSize: 45)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.stars),
                title: const Text("What's New?",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                          url: 'https://navixplore.vercel.app/changelogs'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sos_rounded),
                title: const Text("SOS",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text("Suggest a Feature",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuggestFeature(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text("Report an Issue",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportIssue(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text("Change Language",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share with Friends",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.newspaper_rounded),
                title: const Text("Advertise with us",
                    style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                          url:
                              'https://navixplore.vercel.app/advertise-with-us'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.support),
                title: const Text("Support",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              ListTile(
                leading: const Icon(Icons.note_alt),
                title: const Text("Term & Conditions",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              if (FirebaseAuthService().currentUser != null &&
                  !FirebaseAuthService().currentUser!.isAnonymous)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orange),
                  title: const Text("Sign Out",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      )),
                  onTap: () async {
                    await FirebaseAuthService().signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                  },
                ),
              if (FirebaseAuthService().currentUser == null ||
                  FirebaseAuthService().currentUser!.isAnonymous)
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.orange),
                  title: const Text("Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontFamily: "Fredoka",
                        fontWeight: FontWeight.bold,
                      )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: GNav(
          color: Colors.black,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.orange.shade800,
          hoverColor: Colors.orange.shade700,
          gap: 0,
          iconSize: 24,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              gap: 10,
              icon: Icons.emoji_transportation,
              text: "Transports",
            ),
            GButton(
              gap: 10,
              icon: Icons.explore,
              text: "Explore",
            ),
            GButton(
              gap: 10,
              icon: Icons.newspaper,
              text: "News",
            ),
            GButton(
              gap: 10,
              icon: Icons.person,
              text: "Profile",
            )
          ],
        ),
      ),
    );
  }
}
