import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:navixplore/services/NM_Metro_Service.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';
import 'package:navixplore/widgets/Skeleton.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class NM_MetroRoutePage extends StatefulWidget {
  String lineID;
  String direction;
  String trainName;
  int trainNo;

  NM_MetroRoutePage({
    required this.lineID,
    required this.direction,
    required this.trainName,
    required this.trainNo,
  });

  @override
  State<NM_MetroRoutePage> createState() => _NM_MetroRoutePageState();
}

class _NM_MetroRoutePageState extends State<NM_MetroRoutePage> {
  List<dynamic>? metroScheduleList;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};
  final PanelController panelController = PanelController();
  final Completer<GoogleMapController> _controller = Completer();
  late String _mapStyle;
  bool isLoading = true;

  final NM_MetroService _nmMetroService = NM_MetroService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    await _nmMetroService.fetchAllStations();
    await _addMetroStationMarker();
    await _fetchMetroSchedule();
    await _nmMetroService.fetchPolylinePoints();
    await _addPolyline();
    setState(() {
      isLoading = false;
    });
  }


  Future<void> _fetchMetroSchedule() async {
    try {
      final metroSchedule = await FirestoreService().getDocumentWithMultipleFilter(
        collection: 'NM-Metro-Schedules',
        filters: [
          {'field': 'lineID', 'value': widget.lineID},
          {'field': 'direction', 'value': widget.direction},
        ],
      );

      if (metroSchedule.docs.isNotEmpty) {
        // Assuming metroSchedule.docs contains the fetched documents
        final List<dynamic> schedules = metroSchedule.docs.first.get('schedules');

        // Process the schedules data
        List<dynamic> trainSchedule = [];
        schedules.forEach((schedule) {
          final trainTime = schedule['time'][widget.trainNo];
          if (trainTime != null) {
            trainSchedule.add({
              'stationID': schedule['stationID'],
              'time': trainTime,
            });
          }
        });

        // Now you can use trainSchedule as needed, e.g., update UI or store in state
        setState(() {
          metroScheduleList = trainSchedule;
          metroScheduleList = addStationNameToSchedule(_nmMetroService.allMetroStations, metroScheduleList!);
        });

      }
    } catch (e) {
      // Handle errors, e.g., Firestore service errors
      print('Error fetching metro schedule: $e');
    }
  }



  List<dynamic> addStationNameToSchedule(
      List<dynamic> stationsList, List<dynamic> scheduleList) {
    Map<String, dynamic> stationNameMap = {
      for (var station in stationsList)
        station['stationID']: {
          'English': station['stationName']['English'],
          'Marathi': station['stationName']['Marathi']
        }
    };

    for (var schedule in scheduleList) {
      schedule['stationName'] = stationNameMap[schedule['stationID']];
    }

    return scheduleList;
  }

  String _formatTime(String time24) {
    final DateFormat inputFormat = DateFormat.Hm(); // 24-hour format
    final DateFormat outputFormat =
    DateFormat.jm(); // 12-hour format with AM/PM
    final DateTime dateTime = inputFormat.parse(time24);
    return outputFormat.format(dateTime);
  }

  // Function to add polyline based on latitude and longitude points
  Future<void> _addPolyline() async {
    List<LatLng> polylinePoints = [];

    // Convert latitude and longitude points to LatLng objects
    for (var point in _nmMetroService.polylines) {
      polylinePoints.add(LatLng(point['latitude'], point['longitude']));
    }

    // Add polyline to the map
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('polyline'),
          color: Colors.orange,
          points: polylinePoints,
          width: 3,
        ),
      );
    });
  }

  Future<void> _addMetroStationMarker() async {
    for (var station in _nmMetroService.allMetroStations) {
      final markerBitmap =
      await metroStationMarker(station['stationName']['English'])
          .toBitmapDescriptor(
        logicalSize: const Size(500, 250),
        imageSize: const Size(500, 250),
      );

      // Create a LatLng object
      LatLng stationLatLng = LatLng(
          station['location']['_latitude'], station['location']['_longitude']);

      // Add marker to the set
      markers.add(
        Marker(
          markerId: MarkerId(station['stationName']['English']),
          icon: markerBitmap,
          position: stationLatLng,
        ),
      );
    }

    // Force a rebuild to update the map with markers
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
          ),
        ),
        body: isLoading
            ? _buildLoadingScreen()
            : Stack(
          children: [
            SlidingUpPanel(
              defaultPanelState: PanelState.OPEN,
              maxHeight: 500,
              minHeight: 100,
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              controller: panelController,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              body: GoogleMap(
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(19.038901, 73.06716),
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(_mapStyle);
                },
                markers: markers,
                polylines: _polylines,
              ),
              panel: Column(
                children: [
                  InkWell(
                    onTap: () {
                      panelController.isPanelOpen
                          ? panelController.close()
                          : panelController.open();
                    },
                    child: Container(
                      width: 30,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Text(
                    widget.trainName,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: metroScheduleList!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.all(10.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/icons/NM_Metro.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(metroScheduleList![index]['stationName']
                              ['English']),
                          subtitle: Text(metroScheduleList![index]
                              ['stationName']['Marathi']),
                          trailing: Text(
                            _formatTime(metroScheduleList![index]['time']),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
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
                child: const CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                  child: BackButton(
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ],
        ),);
  }

  Widget metroStationMarker(String stationName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/icons/NM_Metro.png',
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            stationName,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mapSkeleton(
            height: 350,
            width: MediaQuery.of(context).size.width,
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Skeleton(height: 50, width: 50),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Skeleton(height: 8, width: 100),
                  ),
                  subtitle: Skeleton(height: 8, width: 50),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget mapSkeleton({required double height, required double width}) {
    return Skeleton(
      height: height,
      width: width,
    );
  }
}
