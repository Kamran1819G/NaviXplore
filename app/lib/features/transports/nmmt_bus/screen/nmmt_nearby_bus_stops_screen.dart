import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/features/transports/nmmt_bus/screen/nmmt_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'nmmt_bus_stop_buses_screen.dart';

class NMMT_NearbyBusStopsScreen extends StatefulWidget {
  List<dynamic>? nearbyBusStop;

  NMMT_NearbyBusStopsScreen({Key? key, this.nearbyBusStop}) : super(key: key);

  @override
  State<NMMT_NearbyBusStopsScreen> createState() =>
      _NMMT_NearbyBusStopsScreenState();
}

class _NMMT_NearbyBusStopsScreenState extends State<NMMT_NearbyBusStopsScreen> {
  List<dynamic>? nearbyBusStop;
  List<Marker> markers = [];
  Map<String, dynamic>? selectedBusStop;
  bool isLoading = true;
  double? latitude;
  double? longitude;
  Timer? _timer;
  final MapController mapController = MapController();
  PanelController panelController = PanelController();
  final NMMTController controller = Get.put(NMMTController());

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initialize() async {
    await _getUserLocation(); // Get user location first
    if (widget.nearbyBusStop != null) {
      nearbyBusStop = widget.nearbyBusStop;
      await setCustomMarkers();
      isLoading = false;
    } else {
      await _calculateNearbyBusStops();
    }

    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _calculateNearbyBusStops();
    });
  }

  Future<void> _getUserLocation() async {
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
        await _getUserLocation();
        return;
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _calculateNearbyBusStops() async {
    print("Calculating nearby bus stops...");
    print("User Location: Latitude=$latitude, Longitude=$longitude");
    if (latitude == null || longitude == null) {
      // Handle the case where location isn't available yet
      return;
    }

    print("allBusStops length: ${controller.allBusStops.length}");
    if (controller.allBusStops.isEmpty) {
      await controller.fetchAllStations();
      print("allBusStops length: ${controller.allBusStops.length}");
    }

    setState(() {
      isLoading = true;
    });

    final userLatlng = LatLng(latitude!, longitude!);

    // Create a list to hold the bus stops with calculated distances
    List<dynamic> busStopsWithDistance = [];

    // Iterate through each bus stop in allBuses
    for (final busStop in controller.allBusStops) {
      final stationLat = busStop['location']['latitude'] as double?;
      final stationLon = busStop['location']['longitude'] as double?;
      final stationNameEnglish = busStop['stationName']['English'] as String?;
      final stationNameMarathi = busStop['stationName']['Marathi'] as String?;
      final stationId = busStop['stationID'] as int?;
      final buses = busStop['buses'] as String?;

      if (stationLat != null &&
          stationLon != null &&
          stationNameEnglish != null &&
          stationNameMarathi != null &&
          stationId != null) {
        final stationLatlng = LatLng(stationLat, stationLon);

        double distance = calculateDistance(userLatlng, stationLatlng);

        busStopsWithDistance.add({
          'StationName': stationNameEnglish,
          'StationName_M': stationNameMarathi,
          'StationId': stationId.toString(),
          'Center_Lat': stationLat.toString(),
          'Center_Lon': stationLon.toString(),
          'Distance': distance.toString(),
          'Buses': buses.toString(),
        });
      }
    }
    // Sort bus stops by distance
    busStopsWithDistance.sort((a, b) {
      double distanceA = double.tryParse(a['Distance']?.toString() ?? '0') ?? 0;
      double distanceB = double.tryParse(b['Distance']?.toString() ?? '0') ?? 0;
      return distanceA.compareTo(distanceB);
    });

    // Get the top 20 bus stops, or all if less than 20
    final top20BusStops = busStopsWithDistance.take(20).toList();

    setState(() {
      nearbyBusStop = top20BusStops;
      isLoading = false;
    });
    await setCustomMarkers();
  }

  //Distance Calculation
  double calculateDistance(LatLng latLng1, LatLng latLng2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    double lat1 = degreesToRadians(latLng1.latitude);
    double lon1 = degreesToRadians(latLng1.longitude);
    double lat2 = degreesToRadians(latLng2.latitude);
    double lon2 = degreesToRadians(latLng2.longitude);

    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;

    double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
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

  void _handleBusStopTap(
      BuildContext context, Map<String, dynamic> busStopData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NMMT_BusStopBusesScreen(
          busStopName: busStopData["StationName"],
          stationid: int.parse(busStopData["StationId"]),
          stationLocation: {
            'latitude': double.parse(busStopData['Center_Lat']),
            'longitude': double.parse(busStopData['Center_Lon']),
          },
        ),
      ),
    );
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
                        _calculateNearbyBusStops();
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
                double.parse(element["Center_Lat"] ?? "0.0") ==
                    marker.point.latitude &&
                double.parse(element["Center_Lon"] ?? "0.0") ==
                    marker.point.longitude);

            return Marker(
              point: marker.point,
              width: 30,
              height: 30,
              child: GestureDetector(
                  onTap: () {
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
          child: selectedBusStop == null
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
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            "Buses: ${selectedBusStop!["Buses"]}",
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
      itemCount: nearbyBusStop!.length,
      itemBuilder: (context, index) {
        final busStopData = nearbyBusStop![index];
        return Center(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            onTap: () {
              _handleBusStopTap(context, busStopData);
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
              "Buses: ${busStopData["Buses"]}",
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/animations/search.gif',
          ),
          const SizedBox(height: 24),
          Text(
            'Finding Nearby Bus Stops',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Please wait while we find the nearest bus stops for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
