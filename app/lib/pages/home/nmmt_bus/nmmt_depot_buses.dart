import 'dart:async';
import 'package:flutter/services.dart';
import 'package:navixplore/pages/home/nmmt_bus/nmmt_bus_number_search_page.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navixplore/pages/home/nmmt_bus/nmmt_bus_route_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
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
  Set<Marker> markers = {};
  Map<String, dynamic> markerData = {};
  bool isLoading = true;
  Timer? _timer;
  BitmapDescriptor? busStopMarker;
  PanelController panelController = PanelController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initialize();
  }

  void initialize() async{
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

    final busStopMarker = await busStopMarkerWidget().toBitmapDescriptor(
      logicalSize: const Size(150, 150),
      imageSize: const Size(200, 200),
    );
    setState(() {
      this.busStopMarker = busStopMarker;
    });

    // Add a marker for the bus stop
    newMarkers.add(
      Marker(
        markerId: MarkerId(widget.busStopName),
        position: LatLng(
          widget.stationLocation['_latitude'],
          widget.stationLocation['_longitude'],
        ),
        icon: busStopMarker,
        infoWindow: InfoWindow(
          title: widget.busStopName,
        ),
      ),
    );

    // Add markers for running buses using WidgetToMarker
    for (final busData in allBuses!) {
      final latitude = busData['lattitude'] as String?;
      final longitude = busData['longitude'] as String?;
      if (latitude != null &&
          longitude != null &&
          latitude.isNotEmpty &&
          longitude.isNotEmpty) {
        final busLatitude = double.parse(latitude);
        final busLongitude = double.parse(longitude);

        // Check if the marker already exists
        if (markerData.containsKey(busData['BusNo'])) {
          // If it exists, update its position and other properties
          final existingMarker = markerData[busData['BusNo']];
          final updatedMarker = Marker(
            markerId: existingMarker.markerId,
            position: LatLng(busLatitude, busLongitude),
            icon: existingMarker.icon,
            infoWindow: existingMarker.infoWindow,
            // Add other properties as needed
          );
          markerData[busData['BusNo']] = updatedMarker;
          newMarkers.add(updatedMarker);
        } else {
          // If it doesn't exist, create a new marker
          final busMarkerWidget = BusMarker(routeNo: busData['RouteNo']);
          final busMarkerBitmap = await busMarkerWidget.toBitmapDescriptor(
            logicalSize: const Size(150, 150),
            imageSize: const Size(200, 200),
          );

          final newMarker = Marker(
            markerId: MarkerId(busData['BusNo'] as String? ?? 'Unknown'),
            position: LatLng(busLatitude, busLongitude),
            icon: busMarkerBitmap,
            infoWindow: InfoWindow(
              title: '${busData['RouteName'] as String? ?? 'Unknown'}',
              snippet: busData['BusNo'] as String? ?? 'Unknown',
            ),
          );

          // Save the new marker to the mapping
          markerData[busData['BusNo']] = newMarker;
          newMarkers.add(newMarker);
        }
      }
    }

    // Update the state with the new markers
    setState(() {
      markers = newMarkers.toSet();
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
        if (xml.XmlDocument.parse(response.data).innerText.trim().toUpperCase() ==
            "NO BUS AVAILABLE") {
          setState(() {
            allBuses = [];
          });
        } else {
          allBuses = json.decode(xml.XmlDocument.parse(response.data).innerText);

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
      return _buildLoadingSkeleton();
    } else if (allBuses?.isEmpty == true) {
      return _buildNoBusesAvailable();
    } else {
      return _buildRunningBuses();
    }
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mapSkeleton(height: 500, width: MediaQuery.of(context).size.width),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (context, index) => SizedBox(height: 30),
                itemBuilder: (context, index) => busSkeleton(),
              ),
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
            body: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.stationLocation['_latitude'],
                  widget.stationLocation['_longitude'],
                ),
                zoom: 15.0,
              ),
              markers: markers,
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
                    Tab(text: 'Running'),
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
                    child: Icon(Icons.refresh, color: Theme.of(context).primaryColor))),
          ),
        ],
      ),
    );
  }

  Widget _buildBusesList(List<dynamic>? buses) {
    return buses == null
        ? _buildLoadingSkeleton()
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
                              routeid: int.parse(busData["RouteId"]),
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
                                    style: TextStyle(color: Theme.of(context).primaryColor),
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

  Widget mapSkeleton({required double height, required double width}) {
    return Center(
      child: Skeleton(
        height: height,
        width: width,
      ),
    );
  }

  Widget busStopMarkerWidget() {
    return CircleAvatar(
      radius: 30.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.white,
        child: Icon(Icons.directions_bus, color: Theme.of(context).primaryColor, size: 30),
      ),
    );
  }
}
