import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/features/transports/nmmt_bus/controller/nmmt_controller.dart';
import 'package:navixplore/features/announcement_detail_screen.dart';
import 'package:navixplore/features/transports/nmmt_bus/model/nearby_bus_stop_model.dart';
import 'package:navixplore/features/transports/nmmt_bus/screen/nmmt_nearby_bus_stops_screen.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';
import 'package:navixplore/features/widgets/announcement_card.dart';
import 'package:navixplore/features/widgets/webview_screen.dart';
import 'nmmt_bus_search_screen.dart';
import 'nmmt_bus_stop_buses_screen.dart';

class NMMT_Tab extends StatefulWidget {
  const NMMT_Tab({Key? key}) : super(key: key);

  @override
  State<NMMT_Tab> createState() => _NMMT_TabState();
}

class _NMMT_TabState extends State<NMMT_Tab> {
  List<NearbyBusStopModel>? nearbyBusStop; // Using NearbyBusStopModel
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

  Future<void> initialize() async {
    await _getUserLocation(); // Get user location first
    if (latitude != null && longitude != null) {
      await _calculateNearbyBusStops(); // Calculate nearby bus stops if location is available
    }
    try {
      await controller.fetchAnnouncements();
      setState(() {
        isAnnouncementLoading = false;
      });
    } catch (e) {
      print('Error fetching announcements: $e');
      setState(() {
        isAnnouncementLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load announcements. Please try again later.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      if (latitude != null && longitude != null) {
        _calculateNearbyBusStops();
      }
    });
    await setCustomMarkers();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      isLoading = true; // Start loading for location and bus stops
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location services are disabled. Please enable them to find nearby bus stops.'),
            duration: Duration(seconds: 5),
          ),
        );
        setState(() {
          isLoading = false; // Stop loading indicator for bus stops
        });
        return; // Exit if location services are disabled
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale could be used).
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are denied. Please grant location permission to find nearby bus stops.'),
              duration: Duration(seconds: 5),
            ),
          );
          setState(() {
            isLoading = false; // Stop loading indicator for bus stops
          });
          return; // Exit if permissions are denied
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location permissions are permanently denied. Please enable them in app settings to find nearby bus stops.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
        setState(() {
          isLoading = false; // Stop loading indicator for bus stops
        });
        return; // Exit if permissions are denied forever
      }

      // When permissions are granted, get position.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location. Please try again later.'),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {
        isLoading = false; // Stop loading indicator for bus stops
      });
    }
  }

  Future<void> _calculateNearbyBusStops() async {
    print("Calculating nearby bus stops...");
    print("User Location: Latitude=$latitude, Longitude=$longitude");
    if (latitude == null || longitude == null) {
      // Handle the case where location isn't available yet - should not reach here now due to location check in initialize and timer
      return;
    }

    print("allBusStops length: ${controller.allBusStops.length}");
    if (controller.allBusStops.isEmpty) {
      await controller.fetchAllStations();
      print("allBusStops length after fetch: ${controller.allBusStops.length}");
    }

    if (controller.allBusStops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load bus stop data. Please try again later.'),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }


    final userLatlng = LatLng(latitude!, longitude!);

    // Create a list to hold the bus stops with calculated distances
    List<NearbyBusStopModel> busStopsWithDistance = []; // Using NearbyBusStopModel

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

        busStopsWithDistance.add(NearbyBusStopModel( // Using NearbyBusStopModel constructor
          stationName: stationNameEnglish,
          stationNameMarathi: stationNameMarathi,
          stationId: stationId.toString(),
          centerLat: stationLat,
          centerLon: stationLon,
          distance: distance,
          buses: buses.toString(),
        ));
      }
    }
    // Sort bus stops by distance
    busStopsWithDistance.sort((a, b) {
      double distanceA = a.distance ?? 0;
      double distanceB = b.distance ?? 0;
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
              busStopData.centerLat,
              busStopData.centerLon,
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

  String formatDistance(double distanceInKm) {

    if (distanceInKm >= 1) {
      return '${distanceInKm.toStringAsFixed(2)} km';
    } else {
      int meters = (distanceInKm * 1000).round();
      return '$meters m';
    }
  }

  String calculateTime(double distanceInKm) {
    double time = distanceInKm / 0.08;
    if (time < 1) {
      return '1 min';
    }
    return '${time.toStringAsFixed(0)} min';
  }

  Future<void> _handleAnnouncementTap(Map<String, dynamic> announcement) async {
    _navigateToAnnouncement(announcement);
  }

  void _navigateToAnnouncement(Map<String, dynamic> announcement) {
    if (announcement['link'] != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebView_Screen(
                  url: announcement['link'], title: announcement['title'])));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AnnouncementDetailPage(announcement: announcement)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // To make RefreshIndicator work always
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
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
                    border: Border.all(
                        width: 1, color: Theme.of(context).primaryColor),
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
              const SizedBox(height: 10),
              // Nearest Bus Stop Section
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
                      "😢 Oops! No nearby bus stops found.",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Please check your location settings or try again later.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center),
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
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NMMT_BusStopBusesScreen(
                                busStopName: busStopData.stationName,
                                stationid:
                                int.parse(busStopData.stationId),
                                stationLocation: {
                                  'latitude':
                                      busStopData.centerLat,
                                  'longitude':
                                      busStopData.centerLon,
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
                          busStopData.stationName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          busStopData.stationNameMarathi,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${busStopData.buses}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                    trailing: Column(
                      children: [
                        Text(
                          calculateTime(busStopData.distance),
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "~ ${formatDistance(busStopData.distance)}",
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
              // News & Updates Section
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
                  separatorBuilder: (context, index) =>
                      SizedBox(width: 10),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = controller.announcements[index];
                    return GestureDetector(
                      onTap: () => _handleAnnouncementTap(announcement),
                      child: AnnouncementCard(
                        imageUrl: announcement["imageUrl"],
                        title: announcement["title"],
                        description: announcement["description"],
                        releaseAt: announcement["releaseAt"],
                        source: announcement["source"],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(width: 10),
                ),
              ),
              const SizedBox(height: 15),
              // Bus Stops Around You Section
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
                            builder: (context) =>
                                NMMT_NearbyBusStopsScreen(),
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
        ),
      ),
    );
  }

  Future<void> _pullToRefresh() async {
    setState(() {
      isLoading = true;
      isAnnouncementLoading = true;
      nearbyBusStop = null; // Clear existing data to show loading again
      markers.clear();
    });
    await initialize(); // Re-initialize data
  }

  Widget busStopSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeleton(
              height: 40,
              width: 40,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Skeleton(
                      height: 20,
                      width: double.infinity,
                    ),
                    SizedBox(height: 5),
                    Skeleton(
                      height: 15,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ],
                ),
              ),
            ),
            Skeleton(
              height: 30,
              width: 70,
            ),
          ],
        ),
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
              width: double.infinity,
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
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: double.infinity,
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
