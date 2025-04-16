import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/features/transports/express_train/express_tab.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_tab.dart';
import 'package:navixplore/features/transports/nmmt_bus/screen/nmmt_tab.dart';

class TransportsScreen extends StatefulWidget {
  const TransportsScreen({super.key});

  @override
  State<TransportsScreen> createState() => _TransportsScreenState();
}

class _TransportsScreenState extends State<TransportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static const double _tabBarHeight = 90.0; // Constant for TabBar height
  static const double _sectionVerticalPadding = 25.0; // Constant for vertical spacing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        initialIndex: 0,
        vsync: this,
        animationDuration: const Duration(milliseconds: 0)); // Explicitly no animation
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Open navigation menu',
                onPressed: () {
                  if (Scaffold.maybeOf(context) != null && Scaffold.of(context).hasDrawer) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    print("No drawer found in this context."); // Optional: Handle no drawer case
                  }
                },
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontFamily: "Fredoka", fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: "Navi",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20)),
                    TextSpan(
                        text: "X",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 25)),
                    TextSpan(
                        text: "plore",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20)),
                  ],
                ),
              ),
              IconButton(
                  tooltip: 'Go to Onboarding', // Accessibility tooltip
                  icon: Icon(CupertinoIcons.cube_box_fill,
                      color: Theme.of(context).primaryColor),
                  onPressed: () => Get.toNamed(AppRoutes.ONBOARDING)),
            ],
          ),
        ),
        SizedBox(height: _sectionVerticalPadding),
        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: _tabBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TabBar(
            controller: _tabController,
            unselectedLabelColor: Colors.black,
            labelColor: Colors.white,
            dividerHeight: 0,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: <Widget>[
              Tab(
                icon: Image.asset(
                  "assets/images/NMMT Bus.png",
                  height: 40,
                ),
                text: "Bus",
              ),
              Tab(
                icon: Image.asset("assets/images/metro.png", height: 40),
                text: "Metro",
              ),
              Tab(
                icon: Image.asset(
                  "assets/images/express_train.png",
                  height: 40,
                ),
                text: "Express",
              ),
            ],
          ),
        ),

        SizedBox(height: _sectionVerticalPadding),

        //TabsView
        Expanded(
          child: Container(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Consider removing if swipe is desired
              children: [
                NMMT_Tab(),
                NMM_Tab(),
                ExpressTab(),
              ],
            ),
          ),
        )
      ],
    );
  }
}