import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:navixplore/presentation/controllers/nmmt_controller.dart';
import 'package:navixplore/presentation/widgets/Skeleton.dart';
import 'package:xml/xml.dart' as xml;

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
  bool isLoading = true;
  Timer? _timer;
  final String busServiceTypeId = "0";
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  int? sourceLocationId;
  int? destinationLocationId;

  final NMMTController controller = Get.find<NMMTController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await controller.fetchAllStations();
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

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusFromSourceToDestination}?FromLocId=$sourceLocation&ToLocId=$destinationLocation&BusServiceTypeId=$busServiceTypeId&ScheduleDate=$scheduleDate&JourneyTime=$currentTime',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
                .innerText
                .trim()
                .toUpperCase() ==
            "NO BUS AVAILABLE") {
          setState(() {
            busDataList = [];
          });
        } else {
          final List<dynamic> buses =
              json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            busDataList = buses;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              color: Theme.of(context).primaryColor,
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
                          color: Theme.of(context).primaryColor,
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
                      return controller.allBusStops
                              .where((stop) =>
                                  stop['stationName']['English']
                                      ?.toLowerCase()
                                      ?.contains(pattern.toLowerCase()) ??
                                  false ||
                                      stop['stationName']['Marathi']
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
                          backgroundColor: Theme.of(context).primaryColor,
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.directions_bus,
                                color: Theme.of(context).primaryColor,
                                size: 20),
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
                          color: Theme.of(context).primaryColor,
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
                      return controller.allBusStops
                              .where((stop) =>
                                  stop['stationName']['English']
                                      ?.toLowerCase()
                                      ?.contains(pattern.toLowerCase()) ??
                                  false ||
                                      stop['stationName']['Marathi']
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
                          backgroundColor: Theme.of(context).primaryColor,
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.directions_bus,
                                color: Theme.of(context).primaryColor,
                                size: 20),
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
                          backgroundColor: Theme.of(context).primaryColor,
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
                            backgroundColor: Theme.of(context).primaryColor),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      )
                    ]),
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
                      child: _buildSearchOption(
                          Icons.numbers_rounded, "Bus Number"),
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
                      child:
                          _buildSearchOption(Icons.directions_bus, "Bus Stop"),
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
        border: Border.all(width: 2, color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
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
                              child: Text(
                                'Okay, View Route',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
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
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
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
                          color: Theme.of(context).primaryColor,
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
