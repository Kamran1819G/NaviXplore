import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:navixplore/presentation/pages/transports/nmmt_bus/nmmt_bus_number_search_page.dart';
import 'package:navixplore/presentation/pages/transports/nmmt_bus/nmmt_bus_route_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:xml/xml.dart' as xml;

import '../../../widgets/Skeleton.dart';
import '../../../widgets/bus_marker.dart';

class NMMTDepotBuses extends StatefulWidget {
  final int stationid;
  final String busStopName;
  final Map<String, dynamic> stationLocation;

  const NMMTDepotBuses({
    Key? key,
    required this.busStopName,
    required this.stationid,
    required this.stationLocation,
  }) : super(key: key);

  @override
  State<NMMTDepotBuses> createState() => _NMMTDepotBusesState();
}

class _NMMTDepotBusesState extends State<NMMTDepotBuses>
    with SingleTickerProviderStateMixin {
  List<dynamic>? allBuses;
  List<dynamic>? runningBuses;
  List<dynamic>? assignedBuses;
  List<Marker> markers = [];
  Map<String, dynamic> markerData = {};
  bool isLoading = true;
  Map<String, dynamic>? selectedBus;
  Timer? _timer;
  final MapController mapController = MapController();
  PanelController panelController = PanelController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initialize();
  }

  void initialize() async {
    await _fetchAllBusesData();
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      _fetchAllBusesData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> setCustomMarkers() async {
    final List<Marker> newMarkers = [];

    // Add a marker for the bus stop
    newMarkers.add(
      Marker(
        point: LatLng(
          widget.stationLocation['latitude'],
          widget.stationLocation['longitude'],
        ),
        width: 30,
        height: 30,
        child: busStopMarkerWidget(context),
      ),
    );

    // Add markers for running buses
    for (final busData in allBuses!) {
      final latitude = busData['lattitude'] as String?;
      final longitude = busData['longitude'] as String?;
      if (latitude != null &&
          longitude != null &&
          latitude.isNotEmpty &&
          longitude.isNotEmpty) {
        final busLatitude = double.parse(latitude);
        final busLongitude = double.parse(longitude);

        final newMarker = Marker(
          point: LatLng(busLatitude, busLongitude),
          width: 75,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBus = busData;
                  panelController.open();
                });
              },
              child: BusMarker(routeNo: busData['RouteNo'])),
        );
        markerData[busData['BusNo']] = newMarker;
        newMarkers.add(newMarker);
      }
    }

    // Update the state with the new markers
    setState(() {
      markers = newMarkers;
    });
  }

  Future<void> _fetchAllBusesData() async {
    try {
      DateTime now = DateTime.now();
      String scheduleDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetDepotBusesList}?LocationId=${widget.stationid}&ScheduleDate=$scheduleDate',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
                .innerText
                .trim()
                .toUpperCase() ==
            "NO BUS AVAILABLE") {
          setState(() {
            allBuses = [];
          });
        } else {
          allBuses =
              json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            runningBuses = allBuses
                ?.where((bus) => bus['BusRunningStatus'] == 'Running')
                .toList();
            assignedBuses = allBuses
                ?.where((bus) => bus['BusRunningStatus'] == 'Assigned')
                .toList();
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allBuses == null) {
      return _buildLoadingScreen();
    } else if (allBuses?.isEmpty == true) {
      return _buildNoBusesAvailable();
    } else {
      return _buildRunningBuses();
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/animations/bus_loading.gif"),
            SizedBox(height: 20),
            Text(
              'Loading Buses...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 32),

            // Loading Indicator
            SizedBox(
              width: double.infinity,
              height: 5,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),

            const SizedBox(height: 24),

            // Connection Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connecting to NMMT Services',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBusesAvailable() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '😢 Currently No Buses Running',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please check back later.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Looking for specific bus information?",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NMMTBusNumberSearchPage()),
                      );
                    },
                    child: Text(
                      'Tap here!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildRunningBuses() {
    setCustomMarkers();
    double currentMaxHeight = MediaQuery.of(context).size.height * 0.6;
    double panelClosedHeight = 100;
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SlidingUpPanel(
            defaultPanelState: PanelState.OPEN,
            maxHeight: currentMaxHeight,
            minHeight: panelClosedHeight,
            controller: panelController,
            panelSnapping: false,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            body: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  widget.stationLocation['latitude'],
                  widget.stationLocation['longitude'],
                ),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.navixplore.navixplore',
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
            panel: Column(
              children: [
                InkWell(
                  onTap: () {
                    panelController.isPanelOpen
                        ? panelController.close()
                        : panelController.open();
                  },
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.busStopName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Colors.black,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Running'),
                          SizedBox(width: 5),
                          Tooltip(
                              triggerMode: TooltipTriggerMode.tap,
                              message: "Shows live GPS-enabled buses.",
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              )),
                        ],
                      ),
                    ),
                    Tab(text: 'Scheduled'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBusesList(runningBuses),
                      _buildBusesList(assignedBuses),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: BackButton(
                    color: Colors.white,
                  )),
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: GestureDetector(
                onTap: () {
                  _fetchAllBusesData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Text(
                        'Refreshing bus position...',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration:
                          Duration(seconds: 2), // Adjust the duration as needed
                    ),
                  );
                },
                child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.refresh,
                        color: Theme.of(context).primaryColor))),
          ),
        ],
      ),
    );
  }

  Widget _buildBusDetails() {
    if (selectedBus == null) {
      return Container(); // Return an empty container or a loading indicator if needed
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedBus!['RouteName'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(selectedBus!["RouteName_M"],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              )),
          SizedBox(height: 10),
          Text(
            'Status: ${selectedBus!['BusRunningStatus'] == 'Running' ? 'Running' : 'Scheduled'}',
            style: TextStyle(
              color: selectedBus!['BusRunningStatus'] == 'Running'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Bus No: ${selectedBus!['BusNo']}',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),
          if (selectedBus!["BusRunningStatus"] == "Running")
            Row(
              children: [
                Text(
                  '${selectedBus!['ETATimeMinute']} min',
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Text('${selectedBus!['ArrivalTime']}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBusesList(List<dynamic>? buses) {
    return buses == null
        ? _buildLoadingScreen()
        : (buses.isEmpty
            ? _buildNoBusesAvailable()
            : ListView.builder(
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final busData = buses[index];
                  return ListTile(
                    contentPadding: EdgeInsets.all(10),
                    onTap: () async {
                      if (busData["BusRunningStatus"] == "Running") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NMMTBusRoutePage(
                              routeid: int.parse(
                                  busData["RouteId"].toString() ?? '0'),
                              busName: busData["RouteName"],
                              busTripId: busData["TripId"],
                              busArrivalTime: busData["ETATime"],
                              busMarkerWidget:
                                  BusMarker(routeNo: busData['RouteNo']),
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
                              routeid: int.parse(
                                  busData["RouteId"].toString() ?? '0'),
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
                            CupertinoIcons.bus,
                            color: Theme.of(context).primaryColor,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              busData['RouteNo'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(busData['RouteName'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(busData["RouteName_M"],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ))
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${busData['BusRunningStatus'] == 'Running' ? 'Running' : 'Scheduled'}',
                          style: TextStyle(
                            color: busData['BusRunningStatus'] == 'Running'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(
                          'Bus No: ${busData['BusNo']}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${busData['ArrivalTime']}'),
                      ],
                    ),
                  );
                },
              ));
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0), // Set app bar height to zero
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
    );
  }

  Widget busStopMarkerWidget(BuildContext context) {
    return CircleAvatar(
      radius: 15.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: CircleAvatar(
        radius: 10.0,
        backgroundColor: Colors.white,
        child: Icon(Icons.directions_bus,
            color: Theme.of(context).primaryColor, size: 15),
      ),
    );
  }
}
