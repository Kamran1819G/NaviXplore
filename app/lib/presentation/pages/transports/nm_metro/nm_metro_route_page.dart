import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/presentation/controllers/nm_metro_controller.dart';
import 'package:navixplore/presentation/widgets/Skeleton.dart';
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
  List<Marker> markers = [];
  List<Polyline> _polylines = [];
  final PanelController panelController = PanelController();
  final MapController mapController = MapController();
  late String _mapStyle;
  bool isLoading = true;

  final NMMetroController controller = Get.find<NMMetroController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    await controller.fetchAllStations();
    await _addMetroStationMarker();
    await _fetchMetroSchedule();
    await controller.fetchPolylinePoints();
    await _addPolyline();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchMetroSchedule() async {
    try {
      final QuerySnapshot metroSchedule = await FirebaseFirestore.instance
          .collection('NM-Metro-Schedules')
          .where('lineID', isEqualTo: widget.lineID)
          .where('direction', isEqualTo: widget.direction)
          .get();

      if (metroSchedule.docs.isNotEmpty) {
        // Assuming metroSchedule.docs contains the fetched documents
        final List<dynamic> schedules =
        metroSchedule.docs.first.get('schedules');

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
          metroScheduleList = addStationNameToSchedule(
              controller.allMetroStations, metroScheduleList!);
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


  Future<void> _addPolyline() async {
    List<LatLng> polylinePoints = controller.polylines.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

    setState(() {
      _polylines.add(
        Polyline(
          points: polylinePoints,
          color: Theme.of(context).primaryColor,
          strokeWidth: 3,
        ),
      );
    });
  }

  Future<void> _addMetroStationMarker() async {
    for (var station in controller.allMetroStations) {
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
          point: stationLatLng,
          width: 30,
          height: 30,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).primaryColor
              ),
              padding: EdgeInsets.all(4),
              child:  Icon(Icons.tram, color: Colors.white, size: 20,)
          ),
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
            body: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(19.038901, 73.06716),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.navixplore.navixplore',
                ),
                PolylineLayer(
                  polylines: _polylines,
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
                  child: Container(
                    width: 30,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Text(
                  widget.trainName,
                  style: TextStyle(
                      fontSize: 22.0, fontWeight: FontWeight.bold),
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
                        title: Text(metroScheduleList![index]
                        ['stationName']['English']),
                        subtitle: Text(metroScheduleList![index]
                        ['stationName']['Marathi']),
                        trailing: Text(
                          _formatTime(metroScheduleList![index]['time']),
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
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
              child: CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.white,
                child: BackButton(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              separatorBuilder: (BuildContext context, int index) => Divider(),
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