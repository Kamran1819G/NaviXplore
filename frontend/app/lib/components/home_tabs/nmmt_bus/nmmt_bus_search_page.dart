import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/config/api_endpoints.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';
import 'package:navixplore/widgets/Skeleton.dart';
import 'package:xml/xml.dart';

import 'nmmt_bus_number_search_page.dart';
import 'nmmt_bus_route_page.dart';
import 'nmmt_bus_stop_search_page.dart';

class NMMTBusSearchPage extends StatefulWidget {
  const NMMTBusSearchPage({Key? key}) : super(key: key);

  @override
  State<NMMTBusSearchPage> createState() => _NMMTBusSearchPageState();
}

class _NMMTBusSearchPageState extends State<NMMTBusSearchPage> {
  List<dynamic>? busDataList;
  List<dynamic>? busStopDataList;
  bool isLoading = true;
  Timer? _timer;
  final String busServiceTypeId = "0";
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  int? sourceLocationId;
  int? destinationLocationId;

  @override
  void initState() {
    super.initState();
    _fetchAllBusStopData();
    _timer = Timer.periodic(Duration(minutes: 2), (Timer timer) {
      _fetchRunningBusData(sourceLocationId, destinationLocationId);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Method to interchange the source and destination values
  void _interchangeLocations() {
    setState(() {
      String tempLocation = sourceLocationController.text;
      sourceLocationController.text = destinationLocationController.text;
      destinationLocationController.text = tempLocation;

      int? tempLocationId = sourceLocationId;
      sourceLocationId = destinationLocationId;
      destinationLocationId = tempLocationId;

      // Fetch running bus data with updated locations
      _fetchRunningBusData(sourceLocationId, destinationLocationId);
    });
  }

  Future<void> _fetchRunningBusData(
      int? sourceLocationId, int? destinationLocationId) async {
    try {
      setState(() {
        isLoading = true;
      });

      String? sourceLocation = sourceLocationId?.toString();
      String? destinationLocation = destinationLocationId?.toString();

      DateTime now = DateTime.now();
      String scheduleDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      String currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.get(Uri.parse(
        '${NMMTApiEndpoints.GetBusFromSourceToDestination}?FromLocId=$sourceLocation&ToLocId=$destinationLocation&BusServiceTypeId=$busServiceTypeId&ScheduleDate=$scheduleDate&JourneyTime=$currentTime',
      ));

      if (response.statusCode == 200) {
        if (XmlDocument.parse(response.body).innerText.trim().toUpperCase() ==
            "NO BUS AVAILABLE") {
          setState(() {
            busDataList = [];
          });
        } else {
          final List<dynamic> buses =
              json.decode(XmlDocument.parse(response.body).innerText);

          setState(() {
            busDataList = buses;
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAllBusStopData() async {
    final busStops = await FirestoreService().getCollection(collection: 'NMMT-Stations');
    busStops.listen((event) {
      setState(() {
        busStopDataList = event.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: const Text(
          "Search NMMT Bus",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Discover NMMT Bus services! Plan your journey and track real-time bus status!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source Station Search Box
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TypeAheadField<dynamic>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: sourceLocationController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.orange,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              sourceLocationController.clear();
                              sourceLocationId = null;
                            });
                          },
                          icon: Icon(Icons.clear, color: Colors.grey),
                        ),
                        hintText: "Source Bus Station",
                        border: InputBorder.none,
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return busStopDataList
                              ?.where((stop) =>
                                  stop?['stationName']['English']
                                      ?.toLowerCase()
                                      ?.contains(pattern.toLowerCase()) ??
                                  false ||
                                      stop?['stationName']['Marathi']
                                          ?.toLowerCase()
                                          ?.contains(pattern.toLowerCase()) ??
                                  false)
                              .toList() ??
                          [];
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.orange,
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.directions_bus,
                                color: Colors.orange, size: 20),
                          ),
                        ),
                        title: Text(suggestion['stationName']['English']),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        sourceLocationController.text =
                            suggestion['stationName']['English'];
                        sourceLocationId = suggestion['stationID'];
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Destination Station Search Box
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TypeAheadField<dynamic>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: destinationLocationController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.orange,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              destinationLocationController.clear();
                              destinationLocationId = null;
                              _fetchRunningBusData(
                                  sourceLocationId, destinationLocationId);
                            });
                          },
                          icon: Icon(Icons.clear, color: Colors.grey),
                        ),
                        hintText: "Destination Bus Station",
                        border: InputBorder.none,
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return busStopDataList
                              ?.where((stop) =>
                                  stop?['stationName']['English']
                                      ?.toLowerCase()
                                      ?.contains(pattern.toLowerCase()) ??
                                  false ||
                                      stop?['stationName']['Marathi']
                                          ?.toLowerCase()
                                          ?.contains(pattern.toLowerCase()) ??
                                  false)
                              .toList() ??
                          [];
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.orange,
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.directions_bus,
                                color: Colors.orange, size: 20),
                          ),
                        ),
                        title: Text(suggestion['stationName']['English']),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        destinationLocationController.text =
                            suggestion['stationName']['English'];
                        destinationLocationId = suggestion['stationID'];
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Interchange Button and Search Button
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _interchangeLocations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _fetchRunningBusData(
                              sourceLocationId, destinationLocationId);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      )
                    ]
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading ? _buildLoadingSkeleton() : _buildBusList(),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Search Using",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NMMTBusNumberSearchPage(),
                          ),
                        );
                      },
                      child: _buildSearchOption(Icons.numbers_rounded, "Bus Number"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NMMTBusStopSearchPage(),
                          ),
                        );
                      },
                      child: _buildSearchOption(Icons.directions_bus, "Bus Stop"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOption(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Colors.orange,
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    if (isLoading) {
      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (context, index) => SizedBox(height: 30),
              itemBuilder: (context, index) => busSkeleton(),
            ),
          ),
        ],
      );
    } else {
      return Container(); // Return an empty container if not loading
    }
  }

  Widget _buildBusList() {
    return Column(
      children: [
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: busDataList?.length ?? 0,
            itemBuilder: (context, index) {
              final busData = busDataList![index];
              return ListTile(
                contentPadding: EdgeInsets.all(10),
                onTap: () async {
                  if (busData["BusRunningStatus"] == "Running") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMTBusRoutePage(
                          routeid: busData["RouteId"],
                          busName: busData["RouteName"],
                          busTripId: busData["TripId"],
                          busArrivalTime: busData["ETATime"],
                        ),
                      ),
                    );
                  } else {
                    // Bus is scheduled, show dialog and navigate without passing busTripId and ArrivalTime
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Bus is Scheduled'),
                          content: const Text(
                              'Currently, you can view the route, but unfortunately, real-time bus tracking is not available.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Okay, View Route',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMTBusRoutePage(
                          routeid: busData["RouteId"],
                          busName: busData["RouteName"],
                        ),
                      ),
                    );
                  }
                },
                leading: SizedBox(
                  width: 75,
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_bus,
                        color: Colors.orange,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          busData['RouteNo'],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(busData['RouteName'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(busData["RouteName_M"],
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${busData['BusRunningStatus']}',
                      style: TextStyle(
                        color: busData['BusRunningStatus'] == 'Running'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text('Bus No: ${busData['BusNo']}'),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${busData['ETATimeMinute']} min',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('${busData['ArrivalTime']}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget busSkeleton() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(
                height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 5),
                  Skeleton(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                ],
              ),
              SizedBox(width: 10),
              Skeleton(
                height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
