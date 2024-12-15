import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:xml/xml.dart' as xml;

import '../../../widgets/Skeleton.dart';
import '../../../widgets/bus_marker.dart';
import 'nmmt_depot_buses.dart';

class AllNearestBusStop extends StatefulWidget {
  List<dynamic>? nearbyBusStop;

  AllNearestBusStop({Key? key, this.nearbyBusStop}) : super(key: key);

  @override
  State<AllNearestBusStop> createState() => _AllNearestBusStopState();
}

class _AllNearestBusStopState extends State<AllNearestBusStop> {
  List<dynamic>? nearbyBusStop;
  List<Marker> markers = [];
  Map<String, dynamic>? selectedBusStop;
  bool isLoading = true;
  double? latitude;
  double? longitude;
  Timer? _timer;
  final MapController mapController = MapController();
  PanelController panelController = PanelController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await getCurrentLocation();
    if (widget.nearbyBusStop != null) {
      nearbyBusStop = widget.nearbyBusStop;
      await setCustomMarkers();
      isLoading = false;
    } else {
      await _getNearbyBusStops();
    }
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _getNearbyBusStops();
    });
  }

  Future<void> setCustomMarkers() async {
    final List<Marker> newMarkers = [];

    // Add markers for the bus stops
    for (final busStopData in nearbyBusStop!) {
      newMarkers.add(
        Marker(
          point: LatLng(
            double.parse(busStopData["Center_Lat"] ?? "0.0"),
            double.parse(busStopData["Center_Lon"] ?? "0.0"),
          ),
          width: 30,
          height: 30,
          child: busStopMarkerWidget(context),
        ),
      );
    }

    // Update the state with the new markers
    setState(() {
      markers = newMarkers;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool isLocationServiceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
      } else {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getNearbyBusStops() async {
    try {
      await getCurrentLocation();
      setState(() {
        isLoading = true;
      });

      final dio = Dio();
      final response = await dio.get(
        NMMTApiEndpoints.GetNearByBusStops(latitude!, longitude!),
      );

      if (response.statusCode == 200) {
        final List<dynamic> busStop =
        json.decode(xml.XmlDocument.parse(response.data).innerText);

        setState(() {
          nearbyBusStop = busStop;
          isLoading = false;
        });

        await setCustomMarkers();
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

  String formatDistance(String distanceInKm) {
    double distance = double.parse(distanceInKm);

    if (distance >= 1) {
      return '${distance.toStringAsFixed(2)} km';
    } else {
      int meters = (distance * 1000).round();
      return '$meters m';
    }
  }

  String calculateTime(String distanceInKm) {
    double distance = double.parse(distanceInKm);
    double time = distance / 0.08;
    if (time < 1) {
      return '1 min';
    }
    return '${time.toStringAsFixed(0)} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set app bar height to zero
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).primaryColor,
            statusBarIconBrightness: Brightness.light,
          ),
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
                  _getNearbyBusStops();
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
                    child: Icon(Icons.refresh,
                        color: Theme.of(context).primaryColor))),
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(
          latitude!,
          longitude!,
        ),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.navixplore.navixplore',
        ),
        MarkerLayer(
          markers: markers.map((marker) {
            final busStopData = nearbyBusStop!.firstWhere((element) =>
            double.parse(element["Center_Lat"] ?? "0.0") == marker.point.latitude &&
                double.parse(element["Center_Lon"] ?? "0.0") == marker.point.longitude);

            return Marker(
              point: marker.point,
              width: 30,
              height: 30,
              child: GestureDetector(
                  onTap: (){
                    setState(() {
                      selectedBusStop = busStopData;
                      panelController.open();
                    });
                  },
                  child: busStopMarkerWidget(context)),
            );
          }).toList(),
        ),
      ],
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
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        Text(
          selectedBusStop == null
              ? "Nearby Bus Stops"
              : selectedBusStop!["StationName"],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child:  selectedBusStop == null
              ? buildBusStopList()
              : buildBusStopDetails(),
        ),
      ],
    );
  }
  Widget buildBusStopDetails() {
    if (selectedBusStop == null) {
      return Container(); // Return an empty container or a loading indicator if needed
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedBusStop!["StationName"],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            selectedBusStop!["StationName_M"],
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            "Buses: ${selectedBusStop!["RouteNo"]}",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Time: ${calculateTime(selectedBusStop!["Distance"])}",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                "~ ${formatDistance(selectedBusStop!["Distance"])}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

        ],
      ),
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
                    stationid: int.parse(busStopData["StationId"]),
                    stationLocation: {
                      'latitude': double.parse(busStopData['Center_Lat']),
                      'longitude': double.parse(busStopData['Center_Lon']),
                    },
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 20.0,
              backgroundColor: Theme.of(context).primaryColor,
              child: CircleAvatar(
                radius: 15.0,
                backgroundColor: Colors.white,
                child: Icon(Icons.directions_bus,
                    color: Theme.of(context).primaryColor, size: 20),
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
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Column(
              children: [
                Text(
                  calculateTime(busStopData["Distance"]),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "~ ${formatDistance(busStopData["Distance"])}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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