import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/transports/nmmt_bus/controller/nmmt_controller.dart';
import 'package:navixplore/features/transports/nmmt_bus/screen/nmmt_bus_route_screen.dart';

import '../../../widgets/Skeleton.dart';

class NMMT_BusNumberSearchScreen extends StatefulWidget {
  const NMMT_BusNumberSearchScreen({super.key});

  @override
  State<NMMT_BusNumberSearchScreen> createState() =>
      _NMMT_BusNumberSearchScreenState();
}

class _NMMT_BusNumberSearchScreenState
    extends State<NMMT_BusNumberSearchScreen> {
  bool isLoading = true;
  List<dynamic>? filteredBusData;
  TextEditingController _searchController = TextEditingController();
  String? errorMessage; // To store error message

  final NMMTController controller = Get.find<NMMTController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    try {
      await controller.fetchAllBuses();
      setState(() {
        filteredBusData = controller.allBuses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load bus numbers. Please check your connection.";
      });
      print("Error fetching bus numbers: $e"); // Log the error
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchBusNumber(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBusData = controller.allBuses;
      });
    } else {
      setState(() {
        filteredBusData = controller.allBuses
            .where((bus) => bus['routeName']['English']
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: const Text(
          "Search NMMT Bus Number",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchBusNumber(value);
              },
              decoration: InputDecoration(
                hintText: "Enter Bus Number",
                prefixIcon: Icon(Icons.directions_bus,
                    color: Theme.of(context).primaryColor, size: 20),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchBusNumber('');
                  },
                  icon: _searchController.text.isNotEmpty
                      ? Icon(Icons.clear,
                      color:
                      Theme.of(context).primaryColor.withOpacity(0.9))
                      : Icon(
                    Icons.search,
                    color:
                    Theme.of(context).primaryColor.withOpacity(0.9),
                  ),
                ),
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 10), // Reduced separator height
              itemBuilder: (context, index) => busSkeleton(context),
            )
                : errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
                : filteredBusData == null || filteredBusData!.isEmpty
                ? const Center(
                child: Text("No bus numbers found.")) // No results message
                : ListView.builder(
              itemCount: filteredBusData?.length ?? 0,
              itemBuilder: (context, index) {
                final busData = filteredBusData![index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMT_BusRouteScreen(
                            routeid: busData["routeID"],
                            busName: busData["routeName"]
                            ['English']),
                      ),
                    );
                  },
                  leading: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  title: Text(
                    busData["routeName"]['English'],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    busData["routeName"]['Marathi'],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget busSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Added padding to skeleton
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(
            height: 40, // Fixed height for leading skeleton
            width: 40,  // Fixed width for leading skeleton
          ),
          const SizedBox(width: 10),
          Expanded( // Use Expanded to take remaining width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 20,
                  width: double.infinity, // Use infinity to fill available width
                ),
                const SizedBox(height: 5),
                Skeleton(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5, // Adjusted width for subtitle
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Skeleton(
            height: 40, // Fixed height for trailing skeleton
            width: 40,  // Fixed width for trailing skeleton
          ),
        ],
      ),
    );
  }
}