import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// import 'package:navixplore/components/home_tabs/local_train/local_train_tab.dart';
import 'package:navixplore/components/home_tabs/nmmt_bus/nmmt_bus_tab.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_tab.dart';
import 'package:navixplore/components/home_tabs/express_train/express_tab.dart';

class TransportsScreen extends StatefulWidget {
  const TransportsScreen({Key? key}) : super(key: key);

  @override
  State<TransportsScreen> createState() => _TransportsScreenState();
}

class _TransportsScreenState extends State<TransportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        initialIndex: 0,
        vsync: this,
        animationDuration: Duration(milliseconds: 0));
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
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Text("Navi",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text("X",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 25)),
                  Text("plore",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
              Spacer(),
              IconButton(
                icon: Icon(CupertinoIcons.cube_box_fill, color: Theme.of(context).primaryColor),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 90,
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
              // Tab( icon: Image.asset("assets/images/local train.png", height: 45 ), text: "Local"),
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

        const SizedBox(height: 25),

        //TabsView
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                NMMTBusTab(),
                // LocalTrainTab(),
                NMMetroTab(),
                ExpressTab(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
