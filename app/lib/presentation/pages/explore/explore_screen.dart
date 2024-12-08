import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/pages/explore/famous_places_tab.dart';
import 'package:navixplore/presentation/pages/explore/tourist_destinations_tab.dart';
import 'package:navixplore/presentation/controllers/nm_places_controller.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NMPlacesController _placesController = Get.put(NMPlacesController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _placesController.fetchAllPlaces();
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 5,
          tabs: const <Widget>[
            Tab(text: "Famous Places in Navi Mumbai"),
            Tab(text: "Tourist destinations in Navi Mumbai"),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                FamousPlacesTab(),
                TouristDestinationsTab(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
