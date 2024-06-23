import 'package:flutter/material.dart';
import 'package:navixplore/components/explore_tabs/famous_places_tab.dart';
import 'package:navixplore/components/explore_tabs/tourist_destinations_tab.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        initialIndex: 0,
        vsync: this); // Change the length to match your number of tabs.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/images/NaviMumbai_Illustration.jpg"),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Categories",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: false,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.orange,
            indicatorColor: Colors.orange,
            indicatorWeight: 5,
            tabs: <Widget>[
              Tab(
                text: "Famous Places in Navi Mumbai",
              ),
              Tab(
                text: "Tourist destinations in Navi Mumbai",
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TabBarView(
                controller: _tabController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  FamousPlacesTab(),
                  TouristDestinationsTab(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
