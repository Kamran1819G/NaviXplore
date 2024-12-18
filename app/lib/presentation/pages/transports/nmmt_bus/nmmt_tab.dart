import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/presentation/controllers/nmmt_controller.dart';
import 'package:navixplore/presentation/pages/announcement_detail_screen.dart';
import 'package:navixplore/presentation/pages/transports/nmmt_bus/nmmt_nearby_bus_stops_screen.dart';
import 'package:navixplore/presentation/widgets/Skeleton.dart';
import 'package:navixplore/presentation/widgets/announcement_card.dart';
import 'package:navixplore/presentation/widgets/webview_screen.dart';

import 'nmmt_bus_search_screen.dart';
import 'nmmt_bus_stop_buses_screen.dart';

class NMMT_Tab extends StatefulWidget {
  const NMMT_Tab({Key? key}) : super(key: key);

  @override
  State<NMMT_Tab> createState() => _NMMT_TabState();
}

class _NMMT_TabState extends State<NMMT_Tab> {
  List<dynamic>? nearbyBusStop;
  List<Marker> markers = [];
  final MapController mapController = MapController();
  bool isLoading = true;
  bool isAnnouncementLoading = true;
  double? latitude;
  double? longitude;
  Timer? _timer;
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
    await _calculateNearbyBusStops(); // Calculate nearby bus stops
    try {
      await controller.fetchAnnouncements();
      setState(() {
        isAnnouncementLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isAnnouncementLoading = false;
      });
    }
    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      _calculateNearbyBusStops();
    });
    await setCustomMarkers();
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
    if (nearbyBusStop != null) {
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NMMT_BusSearchScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border:
                    Border.all(width: 1, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/icons/NMMT.png",
                        height: 25,
                      )),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter destination or Bus number",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Nearest Bus Stop",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NMMT_NearbyBusStopsScreen(
                        nearbyBusStop: nearbyBusStop,
                      ),
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemExtent: 70,
                  itemBuilder: (context, index) => busStopSkeleton(),
                )
              : nearbyBusStop == null || nearbyBusStop!.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "😢 Oops! Something went wrong.",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'We couldn\'t retrieve nearby bus stops at the moment.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: nearbyBusStop!.length > 3
                          ? 3
                          : nearbyBusStop!.length, // Limit to 3
                      itemBuilder: (context, index) {
                        final busStopData = nearbyBusStop![index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NMMT_BusStopBusesScreen(
                                  busStopName: busStopData["StationName"],
                                  stationid:
                                      int.parse(busStopData["StationId"]),
                                  stationLocation: {
                                    'latitude':
                                        double.parse(busStopData['Center_Lat']),
                                    'longitude':
                                        double.parse(busStopData['Center_Lon']),
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
                                  color: Theme.of(context).primaryColor,
                                  size: 20),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                busStopData["StationName"],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                            "${busStopData["Buses"]}",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
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
                        );
                      },
                    ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "News & Updates",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 400,
            child: isAnnouncementLoading
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) => announcementSkeleton(),
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = controller.announcements[index];
                      return GestureDetector(
                        onTap: () {
                          if (announcement['link'] != null) {
                            WebView_Screen(
                                url: announcement['link'],
                                title: announcement['title']);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnnouncementDetailPage(
                                  announcement: announcement,
                                ),
                              ),
                            );
                          }
                        },
                        child: AnnouncementCard(
                          imageUrl: announcement["imageUrl"],
                          title: announcement["title"],
                          description: announcement["description"],
                          releaseAt: announcement["releaseAt"],
                          source: announcement["source"],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                  ),
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Bus Stops Around You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isLoading
                ? mapSkeleton(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                  )
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                        initialCenter: LatLng(
                          latitude ?? 0,
                          longitude ?? 0,
                        ),
                        initialZoom: 16,
                        onTap: (tapPosition, latLng) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NMMT_NearbyBusStopsScreen(),
                            ),
                          );
                        }),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.navixplore.navixplore',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Make your everyday travel easy with NMMT and NaviXplore",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/icons/NMMT.png",
                    height: 50,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget busStopSkeleton() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Skeleton(
            height: 40,
            width: 40,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 5),
              Skeleton(
                height: 15,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ],
          ),
          Skeleton(
            height: 30,
            width: MediaQuery.of(context).size.width * 0.2,
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

  Widget announcementSkeleton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            child: Skeleton(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Skeleton(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
