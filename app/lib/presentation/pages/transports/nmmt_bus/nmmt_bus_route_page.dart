import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navixplore/presentation/pages/transports/nmmt_bus/nmmt_bus_number_schedules.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:navixplore/core/utils/color_utils.dart';
import 'package:navixplore/presentation/widgets/Skeleton.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

class NMMTBusRoutePage extends StatefulWidget {
  final int routeid;
  final String busName;
  final String? busTripId;
  final String? busArrivalTime;

  const NMMTBusRoutePage({
    Key? key,
    required this.routeid,
    required this.busName,
    this.busTripId,
    this.busArrivalTime,
  }) : super(key: key);

  @override
  State<NMMTBusRoutePage> createState() => _NMMTBusRoutePageState();
}

class _NMMTBusRoutePageState extends State<NMMTBusRoutePage> {
  bool isLoading = true;
  Timer? _timer;
  List<dynamic>? busStopDataList;
  List<dynamic>? busStopPositionDataList;
  List<dynamic>? busPositionDataList;
  late int routeid;
  Set<Marker> markers = Set();
  BitmapDescriptor? busStopMarker;
  BitmapDescriptor? busMarker;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  PanelController panelController = PanelController();

  @override
  void initState() {
    super.initState();
    routeid = widget.routeid;
    initialize();
  }

  void initialize() async {
    await _fetchAllBusStopData();
    await _fetchBusPositionData();
    await setCustomMarker();
    _timer = Timer.periodic(Duration(seconds: 15), (Timer timer) {
      _fetchBusPositionData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> setCustomMarker() async {
    final busStopMarker = await busStopMarkerWidget().toBitmapDescriptor(
      logicalSize: const Size(150, 150),
      imageSize: const Size(200, 200),
    );
    setState(() {
      this.busStopMarker = busStopMarker;
    });
    final busMarker = await busMarkerWidget().toBitmapDescriptor(
      logicalSize: const Size(150, 150),
      imageSize: const Size(200, 200),
    );
    setState(() {
      this.busMarker = busMarker;
    });
  }

  Future<void> _fetchAllBusStopData() async {
    final busStopQuery = await FirebaseFirestore.instance
        .collection('NMMT-Buses')
        .where('routeID', isEqualTo: widget.routeid)
        .get();

    if (busStopQuery.docs.isNotEmpty) {
      final busStopData =
          busStopQuery.docs.first.data() as Map<String, dynamic>;
      setState(() {
        busStopDataList = busStopData['stations'] as List<dynamic>;
      });

      if (busStopDataList!.isNotEmpty) {
        final firstStationID = busStopDataList![0]['stationid'];
        final lastStationID = busStopDataList!.last['stationid'];
        await _fetchBusStopPositionData(firstStationID, lastStationID);
      }
    }
  }

  Future<void> _fetchBusStopPositionData(
      int firstStationID, int lastStationID) async {
    try {
      String routeIDString = routeid.toString();
      String firstStationIDString = firstStationID.toString();
      String lastStationIDString = lastStationID.toString();

      setState(() {
        isLoading = true;
      });

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusStopsBetweenSoureDestination}?RouteId=$routeIDString&FromStaionId=$firstStationIDString&ToStaionId=$lastStationIDString',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
                .innerText
                .trim()
                .toUpperCase() ==
            "NO DATA FOUND") {
          setState(() {
            busStopPositionDataList = [];
          });
        } else {
          final List<dynamic> busStopPosition =
              json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            busStopPositionDataList = busStopPosition;
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _fetchBusPositionData() async {
    try {
      if (widget.busTripId == null || widget.busArrivalTime == null) {
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusTrackerDetails}?TripId=${widget.busTripId}&TripStatus=1&TripStartTime=${widget.busArrivalTime}',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
                .innerText
                .trim()
                .toUpperCase() ==
            "NO DATA FOUND") {
          setState(() {
            busPositionDataList = [];
          });
        } else {
          final List<dynamic> busPosition =
              json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            busPositionDataList = busPosition;
            isLoading = false;
          });

          // Update the map camera to the current bus position
          if (busPositionDataList != null && busPositionDataList!.isNotEmpty) {
            final busLatitude =
                double.parse(busPositionDataList![0]["CurrentLat"] ?? '0');
            final busLongitude =
                double.parse(busPositionDataList![0]["CurrentLong"] ?? '0');
            (await mapController.future).animateCamera(
              CameraUpdate.newLatLng(LatLng(busLatitude, busLongitude)),
            );
          }
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
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildLoadingScreen()
          : busStopDataList!.isEmpty
              ? _buildNoDataScreen()
              : _buildBusRouteScreen(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0), // Set app bar height to zero
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove app bar shadow
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return '${hour}:${minute.toString().padLeft(2, '0')} ${parts[1]}';
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

  Widget _buildNoDataScreen() {
    return Stack(
      children: [
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
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Oops! No Data Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This route might be temporarily or permanently closed. 😞',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusRouteScreen() {
    markers.clear();
    if (busStopPositionDataList != null) {
      for (final busStopPosition in busStopPositionDataList!) {
        final busLatitude =
            double.parse(busStopPosition['STATIONLAT'] as String? ?? '0');
        final busLongitude =
            double.parse(busStopPosition['STATIONLONG'] as String? ?? '0');
        markers.add(
          Marker(
            markerId:
                MarkerId(busStopPosition['STATIONID'] as String? ?? 'Unknown'),
            position: LatLng(busLatitude, busLongitude),
            icon: busStopMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: busStopPosition['STATIONNAME'] as String? ?? 'Unknown',
              snippet: busStopPosition['STATIONNAME_M'] as String? ?? 'Unknown',
            ),
            zIndex: 1,
          ),
        );
      }
    }

    if (busPositionDataList != null && busPositionDataList!.isNotEmpty) {
      markers.add(
        Marker(
          markerId: MarkerId(widget.busName),
          position: LatLng(
            double.parse(busPositionDataList![0]["CurrentLat"] ?? '0'),
            double.parse(busPositionDataList![0]["CurrentLong"] ?? '0'),
          ),
          icon: busMarker ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.busName,
          ),
          zIndex: 2,
        ),
      );
    }
    double panelMaxHeight = MediaQuery.of(context).size.height * 0.6;
    double panelClosedHeight = 100;

    return Stack(
      children: [
        SlidingUpPanel(
          defaultPanelState: PanelState.OPEN,
          maxHeight: panelMaxHeight,
          minHeight: panelClosedHeight,
          parallaxEnabled: true,
          parallaxOffset: 0.5,
          panelSnapping: false,
          controller: panelController,
          color: hexToColor('#F5F5F5'),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(busPositionDataList?[0]["CurrentLat"] ??
                    busStopPositionDataList![0]['STATIONLAT']),
                double.parse(busPositionDataList?[0]["CurrentLong"] ??
                    busStopPositionDataList![0]['STATIONLONG']),
              ),
              zoom: 15,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
            },
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
              const SizedBox(height: 10),
              Text(
                widget.busName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: busStopDataList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final busStopData = busStopDataList![index];
                    return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.075,
                      isFirst: index == 0,
                      isLast: index == busStopDataList!.length - 1,
                      indicatorStyle: IndicatorStyle(
                        width: 20,
                        iconStyle: IconStyle(
                          iconData: Icons.check,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        indicator: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: busPositionDataList != null &&
                                    busPositionDataList!.isNotEmpty &&
                                    busStopDataList![index]['StationId'] ==
                                        busPositionDataList![index]['STATIONID']
                                ? busPositionDataList![index]
                                            ["CoveredStatus"] ==
                                        "covered"
                                    ? Theme.of(context).primaryColor
                                    : busPositionDataList![index]
                                                ["CoveredStatus"] ==
                                            "notcovered"
                                        ? Colors
                                            .white // Set grey color for notcovered
                                        : Colors.red
                                : Colors.white,
                          ),
                        ),
                      ),
                      beforeLineStyle: LineStyle(
                        thickness: 20,
                        color: Colors.grey.shade300,
                      ),
                      afterLineStyle: LineStyle(
                        thickness: 20,
                        color: Colors.grey.shade300,
                      ),
                      endChild: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NMMTBusNumberSchedules(
                                routeid: routeid,
                                busName: widget.busName,
                                busStopName: busStopData["stationname"],
                                stationid: busStopData["stationid"],
                              ),
                            ),
                          );
                        },
                        title: Text(busStopData['stationname']),
                        subtitle: Text(busStopData['stationname_m']),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              busPositionDataList != null
                                  ? _formatTime(
                                      busPositionDataList![index]["ETA"])
                                  : "",
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              busPositionDataList != null
                                  ? "Distance: " +
                                      busPositionDataList![index]["Distance"] +
                                      "km"
                                  : "",
                            ),
                          ],
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
                )),
          ),
        ),
        Positioned(
          top: 20,
          right: 10,
          child: GestureDetector(
              onTap: () {
                _fetchBusPositionData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    content: Text(
                      'Refreshing Map...',
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

  Widget busStopSkeleton() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          SizedBox(width: 10),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 5),
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
          SizedBox(width: 10),
          Skeleton(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
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
        child: Icon(Icons.directions_bus,
            color: Theme.of(context).primaryColor, size: 30),
      ),
    );
  }

  Widget busMarkerWidget() {
    return CircleAvatar(
        radius: 30.0,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.directions_bus, color: Colors.white, size: 40));
  }
}
