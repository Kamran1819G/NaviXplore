import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_upcoming_trains.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_fare_calculator.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_map.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_penalties.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_search_page.dart';
import 'package:navixplore/widgets/Skeleton.dart';

class NMMetroTab extends StatefulWidget {
  const NMMetroTab({Key? key}) : super(key: key);

  @override
  State<NMMetroTab> createState() => _NMMetroTabState();
}

class _NMMetroTabState extends State<NMMetroTab> {
  bool isLoading = true;
  late double? _currentlatitude;
  late double? _currentlongitude;
  List<dynamic>? metroStationsList;
  List<dynamic>? nearestStationsList;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _fetchMetroStations();
    await _fetchNearestStations();
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

  Future<void> _fetchMetroStations() async {
    final response = await http.get(Uri.parse(NM_MetroApiEndpoints.GetStations));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        metroStationsList = data;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<void> _fetchNearestStations() async {
    if (_currentlatitude != null && _currentlongitude != null) {
      final response = await http.get(Uri.parse(NM_MetroApiEndpoints.GetNearestStation(_currentlatitude!, _currentlongitude!)));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          nearestStationsList = [data];
        });
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } else {
      throw Exception('Current location is not available.');
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
                builder: (context) => NMMetroSearchPage(metroStationsList: metroStationsList),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(width: 1, color: Colors.orange.shade900),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/icons/NM_Metro.png",
                      height: 20),
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
                            animatedTexts: metroStationsList != null
                                ? [
                                    for (var station in metroStationsList!)
                                      RotateAnimatedText(
                                        station["stationName"]["English"],
                                        textStyle: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ]
                                : [
                                    TyperAnimatedText(
                                      "Loading...",
                                      textStyle: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: Colors.orange.shade800,
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
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(width: 10),
            const Text(
              "Nearest Metro Station",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),

        SizedBox(
            height: 75,
            child: isLoading
                ? metroStationSkeleton()
                : ListView.builder(
                  itemCount: nearestStationsList!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NM_MetroUpcomingTrains(lineID: nearestStationsList![index]["lineID"], stationID: nearestStationsList![index]["stationID"], stationName: nearestStationsList![index]["stationName"]["English"]),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
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
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        nearestStationsList![index]["stationName"]["Marathi"],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      trailing: Text(
                        "${nearestStationsList![index]["distance"]} km",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
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
                    color: Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 10),
                const Text("Related to Metro",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          builder: (context) => NM_MetroFareCalculator(metroStationsList: metroStationsList),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.currency_rupee_outlined, size: 40),
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
                          "Metro Penalties",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NM_MetroMap(metroStationsList: metroStationsList,)),
                      );
                    },
                    child: Column(
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
                          "Metro Railmap",
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
