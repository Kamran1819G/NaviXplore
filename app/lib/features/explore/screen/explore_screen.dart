import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/explore/controller/nm_places_controller.dart';
import 'package:navixplore/features/models/restaurant_model.dart';
import 'package:navixplore/features/explore/widget/famous_places_tab.dart';
import 'package:navixplore/features/explore/widget/tourist_destinations_tab.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NMPlacesController _placesController = Get.put(NMPlacesController());

  // Dummy Restaurant Data (replace with your actual data source)
  final List<RestaurantModel> _restaurants = [
    RestaurantModel(
        id: 'restaurant1',
        name: "Hotel ABC",
        imageUrl: "https://via.placeholder.com/150",
        isOnboarded: true,
        memberDiscount: 15.0, // 15% discount for app members
        totalMembershipDeals: 5,
        contactPerson: "John Doe",
        contactEmail: "john@hotelABC.com",
        contactPhone: "+91 1234567890",
        address: "123 Main Street, Navi Mumbai",
        cuisineType: "Multi-cuisine",
        averageMealPrice: 500.0,
        membershipBenefits: [
          "15% off on total bill",
          "Free appetizer with main course",
          "Priority seating"
        ]),
    RestaurantModel(
        id: 'restaurant2',
        name: "Tadka Restaurant",
        imageUrl: "https://via.placeholder.com/150",
        isOnboarded: false,
        memberDiscount: 0.0,
        totalMembershipDeals: 0,
        contactPerson: "John Doe",
        contactEmail: "john@tadka.com",
        contactPhone: "+91 1234567890",
        address: "456 XYZ Street, Navi Mumbai",
        cuisineType: "Indian",
        averageMealPrice: 400.0,
        membershipBenefits: [
        ]
    ),
  ];

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

  void _viewRestaurantDetails(RestaurantModel restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen bottom sheet
      backgroundColor: Colors.transparent, // Make background transparent
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95, // Increased max size for more scrolling space
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background for content
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        restaurant.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (restaurant.memberDiscount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "🎉 ${restaurant.memberDiscount}% Off for Members",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        "Cuisine: ${restaurant.cuisineType} 🍽️",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Average Meal Price: ₹${restaurant.averageMealPrice} 💰",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Contact Information Section
                      const Text(
                        "Contact Information:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("📞 ${restaurant.contactPhone}"),
                      Text("✉️ ${restaurant.contactEmail}"),
                      Text("📍 ${restaurant.address}"),

                      if (restaurant.membershipBenefits.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              "Membership Benefits: 🎁",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...restaurant.membershipBenefits
                                .map((benefit) => Text(
                                      "• $benefit",
                                      style: const TextStyle(fontSize: 15),
                                    ))
                                .toList(),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
