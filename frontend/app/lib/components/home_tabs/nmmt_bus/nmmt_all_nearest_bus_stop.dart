import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/config/api_endpoints.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:xml/xml.dart';

import '../../../widgets/Skeleton.dart';
import 'nmmt_depot_buses.dart';

class AllNearestBusStop extends StatefulWidget {
  const AllNearestBusStop({super.key});

  @override
  State<AllNearestBusStop> createState() => _AllNearestBusStopState();
}

class _AllNearestBusStopState extends State<AllNearestBusStop> {
  List<dynamic>? nearbyBusStop;
  Set<Marker> markers = Set();
  bool isLoading = true;
  double? _latitude;
  double? _longitude;
  BitmapDescriptor? busStopMarker;
  Timer? _timer;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  PanelController panelController = PanelController();

  @override
  void initState() {
    super.initState();
    setCustomMarker();
    _getNearbyBusStops();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _getNearbyBusStops();
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
  }

  Future<void> _getNearbyBusStops() async {
    try {
      if (await Permission.location.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      } else {
        await Permission.location.request();
      }
      setState(() {
        isLoading = true;
      });
      final response = await http.get(Uri.parse(NMMTApiEndpoints.GetNearByBusStops(_latitude!, _longitude!)));
      if (response.statusCode == 200) {
        final List<dynamic> busStop =
            json.decode(XmlDocument.parse(response.body).innerText);
        setState(() {
          nearbyBusStop = busStop;
          isLoading = false;
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set app bar height to zero
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : Stack(
              children: [
                SlidingUpPanel(
                  controller: panelController,
                  defaultPanelState: PanelState.OPEN,
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  minHeight: 75,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  body: buildMap(),
                  panel: buildPanel(),
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
                        backgroundColor: Colors.orange,
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
                        _getNearbyBusStops();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                            content: Text(
                              'Getting Nearby Bus Stops...',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(
                                seconds: 2), // Adjust the duration as needed
                          ),
                        );
                      },
                      child: CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.refresh, color: Colors.orange))),
                ),
              ],
            ),
    );
  }

  Widget buildMap() {
    markers.clear();
    for (int i = 0; i < 15; i++) {
      final busStopData = nearbyBusStop![i];
      if (busStopData != null) {
        markers.add(
          Marker(
            markerId: MarkerId(busStopData["StationName"] ?? ""),
            position: LatLng(
              double.parse(busStopData["Center_Lat"] ?? "0.0"),
              double.parse(busStopData["Center_Lon"] ?? "0.0"),
            ),
            icon: busStopMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: busStopData["StationName"] ?? "",
            ),
            zIndex: 1,
          ),
        );
        if (i == 9) {
          break;
        }
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_latitude!, _longitude!),
        zoom: 16,
      ),
      markers: markers,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      fortyFiveDegreeImageryEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapController.complete(controller);
      },
    );
  }

  Widget buildPanel() {
    return Column(
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
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        Text(
          "Nearby Bus Stops",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: buildBusStopList(),
        ),
      ],
    );
  }

  Widget buildBusStopList() {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        final busStopData = nearbyBusStop![index];
        return Center(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NMMTDepotBuses(
                    busStopName: busStopData["StationName"],
                    stationid: busStopData["StationId"],
                    stationLatitude: busStopData['Center_Lat'],
                    stationLongitude: busStopData["Center_Lon"],
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.orange,
              child: CircleAvatar(
                radius: 15.0,
                backgroundColor: Colors.white,
                child: Icon(Icons.directions_bus, color: Colors.orange, size: 20),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  busStopData["StationName"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  busStopData["StationName_M"],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ],
            ),
            subtitle: Text(
              "Buses: ${busStopData["RouteNo"]}",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey),
            ),
            trailing: Text("${busStopData["Distance"]} km",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                )),
          ),
        );
      },
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
              itemCount: 10,
              separatorBuilder: (context, index) => SizedBox(height: 40),
              itemBuilder: (context, index) => busStopSkeleton(),
            ),
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
      backgroundColor: Colors.orange,
      child: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.white,
        child: Icon(Icons.directions_bus, color: Colors.orange, size: 30),
      ),
    );
  }
}
