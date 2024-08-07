import 'dart:async';
import 'package:navixplore/presentation/pages/transports/nm_metro/nm_metro_upcoming_trains.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navixplore/presentation/pages/transports/nm_metro/nm_metro_fare_calculator.dart';
import 'package:navixplore/presentation/pages/transports/nm_metro/nm_metro_map.dart';
import 'package:navixplore/presentation/pages/transports/nm_metro/nm_metro_penalties.dart';
import 'package:navixplore/presentation/pages/transports/nm_metro/nm_metro_search_page.dart';
import 'package:navixplore/services/NM_Metro_Service.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';
import 'package:navixplore/presentation/widgets/Skeleton.dart';

class NMMetroTab extends StatefulWidget {
  const NMMetroTab({Key? key}) : super(key: key);

  @override
  State<NMMetroTab> createState() => _NMMetroTabState();
}

class _NMMetroTabState extends State<NMMetroTab> {
  bool isLoading = true;
  late double? _currentlatitude;
  late double? _currentlongitude;
  List<dynamic>? nearestStationsList;

  final NM_MetroService _nmMetroService = NM_MetroService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _getCurrentLocation();
    await _nmMetroService.fetchAllStations();
    await fetchNearestStations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentlatitude = position.latitude;
      _currentlongitude = position.longitude;
    });
  }

  Future<void> fetchNearestStations() async {
    if (_currentlatitude == null || _currentlongitude == null) {
      return;
    }

    List<Map<String, dynamic>> stationsWithDistance = [];

    for (var station in _nmMetroService.allMetroStations) {
      double stationLat = station['location']['_latitude'];
      double stationLon = station['location']['_longitude'];

      double distance = Geolocator.distanceBetween(
          _currentlatitude!, _currentlongitude!, stationLat, stationLon);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NMMetroSearchPage(),
              ),
            );
          },
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
                            animatedTexts: _nmMetroService
                                    .allMetroStations.isNotEmpty
                                ? [
                                    for (var station
                                        in _nmMetroService.allMetroStations)
                                      RotateAnimatedText(
                                        station["stationName"]["English"],
                                        textStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
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
        const SizedBox(
          height: 20,
        ),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NM_MetroUpcomingTrains(
                                  lineID: nearestStationsList![index]["lineID"],
                                  stationID: nearestStationsList![index]
                                      ["stationID"],
                                  stationName: nearestStationsList![index]
                                      ["stationName"]["English"]),
                            ),
                          );
                        },
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
                          nearestStationsList![index]["stationName"]["English"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          nearestStationsList![index]["stationName"]["Marathi"],
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

        SizedBox(height: 20),
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
            const SizedBox(height: 15),
            SizedBox(
              height: 150,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                padding: const EdgeInsets.all(10.0),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NM_MetroFareCalculator(),
                        ),
                      );
                    },
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NM_MetroPenalties(),
                        ),
                      );
                    },
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NM_MetroMap()),
                      );
                    },
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
            const SizedBox(height: 25),
            /*Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset("assets/images/Card.png"),
                        const Text(
                          "RECHARGE SMART CARD",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                    ),
              )
     */
          ],
        ),
      ],
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
