import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/nmmt_controller.dart';

import '../../../widgets/Skeleton.dart';
import 'nmmt_bus_stop_buses_screen.dart';

class NMMT_BusStopSearchScreen extends StatefulWidget {
  const NMMT_BusStopSearchScreen({super.key});

  @override
  State<NMMT_BusStopSearchScreen> createState() =>
      _NMMT_BusStopSearchScreenState();
}

class _NMMT_BusStopSearchScreenState extends State<NMMT_BusStopSearchScreen> {
  bool isLoading = true;
  List<dynamic>? filteredBusStopData;
  TextEditingController _searchController = TextEditingController();

  final NMMTController controller = Get.find<NMMTController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await controller.fetchAllStations();
    setState(() {
      filteredBusStopData = controller.allBusStops;
      isLoading = false;
    });
  }

  void _searchBusStops(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBusStopData = controller.allBusStops;
      });
    } else {
      setState(() {
        filteredBusStopData = controller.allBusStops
            .where((busStop) => busStop['stationName']['English']
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
          "Search NMMT Bus Stop",
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
                _searchBusStops(value);
              },
              decoration: InputDecoration(
                hintText: "Enter Bus Stop Name",
                prefixIcon: Icon(Icons.directions_bus,
                    color: Theme.of(context).primaryColor, size: 20),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchBusStops('');
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
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.separated(
                    itemCount: 10,
                    separatorBuilder: (context, index) => SizedBox(height: 40),
                    itemBuilder: (context, index) => busStopSkeleton(),
                  )
                : ListView.builder(
                    itemCount: filteredBusStopData?.length ?? 0,
                    itemBuilder: (context, index) {
                      final busStopData = filteredBusStopData![index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NMMT_BusStopBusesScreen(
                                busStopName: busStopData["stationName"]
                                    ["English"],
                                stationid: busStopData["stationID"],
                                stationLocation: busStopData["location"],
                              ),
                            ),
                          );
                        },
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          width: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              busStopData["stationName"]["English"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              busStopData["stationName"]["Marathi"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          busStopData["cityName"],
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget busStopSkeleton() {
    return Center(
      child: Row(
        children: [
          Skeleton(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: 5),
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ],
          ),
          SizedBox(width: 10),
          Skeleton(
            height: 40,
            width: MediaQuery.of(context).size.width * 0.1,
          ),
        ],
      ),
    );
  }
}
