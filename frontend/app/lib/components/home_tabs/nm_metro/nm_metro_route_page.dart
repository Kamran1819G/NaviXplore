import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:navixplore/config/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  List<dynamic>? metroStationsList;
  List<dynamic>? metroScheduleList;
  List<dynamic>? metroRouteLineDataList;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};
  final PanelController panelController = PanelController();
  final Completer<GoogleMapController> _controller = Completer();
  late String _mapStyle;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    initialize();
  }

  void initialize() async {
    await _fetchMetroStations();
    await _fetchMetroSchedule();
    await _fetchPolylinePoints();
    _addPolyline();
  }

  Future<void> _fetchMetroStations() async {
    final response =
    await http.get(Uri.parse(NM_MetroApiEndpoints.GetStations));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        metroStationsList = data;
        _addMetroStationMarker();
      });
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<void> _fetchMetroSchedule() async {
    final response = await http.get(Uri.parse(
        NM_MetroApiEndpoints.GetMetroSchedule(
            widget.lineID, widget.direction, widget.trainNo)));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)["trainSchedule"];
      setState(() {
        metroScheduleList = addStationNameToSchedule(metroStationsList!, data);
      });
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
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

  Future<void> _fetchPolylinePoints() async {
    final response = await http.get(Uri.parse(
        NM_MetroApiEndpoints.GetlineData(metroStationsList![0]["lineID"])));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)["polylines"];
      setState(() {
        metroRouteLineDataList = data;
      });
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  String _formatTime(String time24) {
    final DateFormat inputFormat = DateFormat.Hm(); // 24-hour format
    final DateFormat outputFormat =
    DateFormat.jm(); // 12-hour format with AM/PM
    final DateTime dateTime = inputFormat.parse(time24);
    return outputFormat.format(dateTime);
  }

  // Function to add polyline based on latitude and longitude points
  void _addPolyline() {
    if (metroRouteLineDataList == null) return;

    List<LatLng> polylinePoints = [];

    // Convert latitude and longitude points to LatLng objects
    for (var point in metroRouteLineDataList!) {
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
    for (var station in metroStationsList!) {
      final markerBitmap =
      await metroStationMarker(station['stationName']['English'])
          .toBitmapDescriptor(
        logicalSize: const Size(500, 250),
        imageSize: const Size(500, 250),
      );

      // Create a LatLng object
      LatLng stationLatLng = LatLng(
          station['location']['latitude'], station['location']['longitude']);

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
        body: Stack(
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
        ));
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
}
