import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/transports/nm_metro/controller/nm_metro_controller.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_fare_calculator_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_map_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_penalties_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_search_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_upcoming_trains_screen.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';

class NMM_Tab extends StatefulWidget {
  const NMM_Tab({Key? key}) : super(key: key);

  @override
  State<NMM_Tab> createState() => _NMM_TabState();
}

class _NMM_TabState extends State<NMM_Tab> {
  bool isLoading = true;
  late double? _currentLatitude;
  late double? _currentlongitude;
  List<dynamic>? nearestStationsList;

  final NMMetroController _controller = Get.put(NMMetroController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initialize() async {
    await _getCurrentLocation();
    await _controller.fetchAllStations();
    await fetchNearestStations();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLatitude = position.latitude;
      _currentlongitude = position.longitude;
    });
  }

  Future<void> fetchNearestStations() async {
    if (_currentLatitude == null || _currentlongitude == null) {
      return;
    }

    List<Map<String, dynamic>> stationsWithDistance = [];

    for (var station in _controller.allMetroStations) {
      double stationLat = station['location']['latitude'];
      double stationLon = station['location']['longitude'];

      double distance = Geolocator.distanceBetween(
          _currentLatitude!, _currentlongitude!, stationLat, stationLon);

      stationsWithDistance.add({
        'stationID': station['stationID'],
        'lineID': station['lineID'],
        'stationName': station['stationName'],
        'location': station['location'],
        'distance': distance,
      });
    }

    // Sort stations by distance
    stationsWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      nearestStationsList = stationsWithDistance;
      isLoading = false;
    });
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(2)} km';
    } else {
      return '${distanceInMeters.round()} m';
    }
  }

  String calculateTime(double distanceInMeters) {
    // Average walking speed: 5 km/h (0.0833 km/min)
    double distanceInKm = distanceInMeters / 1000;
    double timeInMinutes = distanceInKm / 0.0833;

    if (timeInMinutes < 1) {
      return '1 min';
    } else if (timeInMinutes < 60) {
      return '${timeInMinutes.toStringAsFixed(0)} min';
    } else {
      double timeInHours = timeInMinutes / 60;
      return '${timeInHours.toStringAsFixed(1)} hr';
    }
  }

  Future<void> _handleNavigationTap(Widget screen) async {
    _navigateToScreen(screen);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          GestureDetector(
            onTap: () => _handleNavigationTap(NMM_SearchPageScreen()),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border:
                    Border.all(width: 1, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/icons/NM_Metro.png", height: 20),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            "You are at",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedTextKit(
                              repeatForever: true,
                              pause: const Duration(milliseconds: 150),
                              animatedTexts: _controller
                                      .allMetroStations.isNotEmpty
                                  ? [
                                      for (var station
                                          in _controller.allMetroStations)
                                        RotateAnimatedText(
                                          station["stationName"]["English"],
                                          textStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ]
                                  : [
                                      TyperAnimatedText(
                                        "Loading...",
                                        textStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          // Nearest Metro Station
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              const Text(
                "Nearest Metro Station",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2),
              ),
            ],
          ),

          SizedBox(
              height: 75,
              child: isLoading
                  ? metroStationSkeleton()
                  : ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => _handleNavigationTap(
                              NMM_UpcomingTrainsScreen(
                                  lineID: nearestStationsList![index]["lineID"],
                                  stationID: nearestStationsList![index]
                                      ["stationID"],
                                  stationName: nearestStationsList![index]
                                      ["stationName"]["English"])),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/icons/NM_Metro.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(
                            nearestStationsList![index]["stationName"]
                                ["English"],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            nearestStationsList![index]["stationName"]
                                ["Marathi"],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                calculateTime(
                                    nearestStationsList![index]["distance"]),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                              Text(
                                '~ ${formatDistance(nearestStationsList![index]["distance"])}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    )),

          SizedBox(height: 10),
          // Related to Metro
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(width: 10),
                  const Text("Related to Metro",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _handleNavigationTap(NMM_FareCalculatorScreen()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.currency_rupee_outlined,
                                size: 40),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Fare",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _handleNavigationTap(const NMM_PenaltiesScreen()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset("assets/images/Law.png"),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Penalties",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _handleNavigationTap(NMM_MapScreen()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset("assets/images/Map.png"),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Map",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget metroStationSkeleton() {
    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Skeleton(
          height: 40,
          width: 40,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Skeleton(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            SizedBox(height: 5),
            Skeleton(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ],
        ),
        Skeleton(
          height: 30,
          width: MediaQuery.of(context).size.width * 0.2,
        ),
      ]),
    );
  }
}
