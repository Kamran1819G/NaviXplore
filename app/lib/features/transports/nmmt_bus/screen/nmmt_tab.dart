import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart'; // Import for GeoPoint (if needed)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/features/announcement_detail_screen.dart';
import 'package:navixplore/features/transports/nmmt_bus/controller/nmmt_controller.dart';
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
  bool _isLocationServiceEnabled = true; // Track location service status
  bool _isLocationPermissionGranted = true; // Track location permission status

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
    setState(() {
      isLoading = true;
      isAnnouncementLoading = true;
    });
    try {
      await _getUserLocation(); // Get user location first
      if (latitude != null &&
          longitude != null &&
          _isLocationServiceEnabled &&
          _isLocationPermissionGranted) {
        await _calculateNearbyBusStops(); // Calculate nearby bus stops if location is available and services are enabled
        await setCustomMarkers();
      } else {
        nearbyBusStop =
            []; // Set to empty list if location is not available to avoid null errors in UI, and show "No nearby bus stops" message.
      }
      await controller.fetchAnnouncements();
      setState(() {
        isAnnouncementLoading = false;
      });
    } catch (e) {
      print('Error during initialization: $e');
      setState(() {
        isLoading = false;
        isAnnouncementLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Failed to initialize NMMT services. Please try again later.'),
          duration: Duration(seconds: 5),
        ),
      );
    }

    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      if (latitude != null &&
          longitude != null &&
          _isLocationServiceEnabled &&
          _isLocationPermissionGranted) {
        _calculateNearbyBusStops();
      }
    });
  }

  Future<void> _getUserLocation() async {
    setState(() {
      isLoading = true; // Start loading for location and bus stops
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _isLocationServiceEnabled = serviceEnabled;
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
          // Permissions are denied
          _isLocationPermissionGranted = false;
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
        } else {
          _isLocationPermissionGranted =
              true; // Permission granted after request
        }
      } else if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        _isLocationPermissionGranted = false;
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
      } else {
        _isLocationPermissionGranted =
            true; // Permission already granted or granted now.
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
          content:
              Text('Failed to load bus stop data. Please try again later.'),
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
    List<NearbyBusStopModel> busStopsWithDistance =
        []; // Using NearbyBusStopModel

    // Iterate through each bus stop in allBuses
    for (final busStop in controller.allBusStops) {
      final locationData = busStop['location'];
      double? stationLat;
      double? stationLon;

      if (locationData is Map<String, dynamic>) {
        // Check if it's a Map
        stationLat = locationData['latitude'] as double?;
        stationLon = locationData['longitude'] as double?;
      } else if (locationData is GeoPoint) {
        // Check if it's a GeoPoint
        stationLat = locationData.latitude;
        stationLon = locationData.longitude;
      } else {
        print("Unexpected location data type: ${locationData.runtimeType}");
        continue; // Skip this bus stop if location data is not in expected format
      }
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

        busStopsWithDistance.add(NearbyBusStopModel(
          // Using NearbyBusStopModel constructor
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        displacement: 10,
        onRefresh: _pullToRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMT_BusSearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/icons/NMMT.png",
                            height: 24,
                            width: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find bus",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "Enter Destination or Bus No.",
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Nearest Bus Stop
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "Nearest Bus Stop"),
                    const SizedBox(height: 12),
                    isLoading
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) =>
                                _buildBusStopSkeleton(context),
                            itemExtent: 90,
                          )
                        : nearbyBusStop == null || nearbyBusStop!.isEmpty
                            ? _buildNoStationsCard()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: nearbyBusStop!.length > 3
                                    ? 3
                                    : nearbyBusStop!.length,
                                itemBuilder: (context, index) {
                                  final busStopData = nearbyBusStop![index];
                                  return _buildBusStopItem(
                                      context, busStopData);
                                },
                              ),
                    const SizedBox(height: 12),
                    if (nearbyBusStop != null && nearbyBusStop!.isNotEmpty)
                      Center(
                        child: TextButton(
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
                            "View All Nearby Stops",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bus Stops Around You Map
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "Bus Stops Around You"),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isLoading
                          ? Skeleton(
                              height: 200,
                              width: double.infinity,
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NMMT_NearbyBusStopsScreen(),
                                  ),
                                );
                              },
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    latitude ?? 19.0760,
                                    longitude ?? 72.8777,
                                  ),
                                  initialZoom: 16,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.navixplore.navixplore',
                                  ),
                                  MarkerLayer(markers: markers),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // News & Updates
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "News & Updates"),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: isAnnouncementLoading
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 2,
                              itemBuilder: (context, index) =>
                                  _buildAnnouncementSkeleton(context),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 16),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.announcements.length,
                              itemBuilder: (context, index) {
                                final announcement =
                                    controller.announcements[index];
                                return GestureDetector(
                                  onTap: () =>
                                      _handleAnnouncementTap(announcement),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: AnnouncementCard(
                                      imageUrl: announcement["imageUrl"],
                                      title: announcement["title"],
                                      description: announcement["description"],
                                      releaseAt: announcement["releaseAt"],
                                      source: announcement["source"],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 16),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // NMMT Services Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "NMMT Information"),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoItem(
                            context: context,
                            title: "Route Information",
                            icon: Icons.route_rounded,
                            onTap: () {
                              // Navigate to route information page
                            },
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            context: context,
                            title: "Bus Time Schedule",
                            icon: Icons.access_time_rounded,
                            onTap: () {
                              // Navigate to time schedule page
                            },
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            context: context,
                            title: "Bus Services Rules",
                            icon: Icons.rule_rounded,
                            onTap: () {
                              // Navigate to bus rules page
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
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
    // Option 1: Refresh data from Firebase but keep local storage.
    // await controller.refreshAllData();
    // await initialize(); // Re-initialize to update UI based on refreshed data.  This might be redundant if refreshAllData already updates RxLists.

    // Option 2: Clear local storage and then refresh from Firebase - More aggressive refresh, ensures completely fresh data. Good for development/testing.
    await controller
        .clearAndRefreshData(); // Clear local storage and refresh from Firebase
    await initialize(); // Re-initialize to load fresh data and update UI.
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildNoStationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.location_off_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No nearby bus stops found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (!_isLocationServiceEnabled)
                  Text(
                    'Please enable location services',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                if (!_isLocationPermissionGranted && _isLocationServiceEnabled)
                  Text(
                    'Please grant location permission',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopItem(
      BuildContext context, NearbyBusStopModel busStopData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NMMT_BusStopBusesScreen(
              busStopName: busStopData.stationName,
              stationid: int.parse(busStopData.stationId),
              stationLocation: {
                'latitude': busStopData.centerLat,
                'longitude': busStopData.centerLon,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    busStopData.stationName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    busStopData.stationNameMarathi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Buses: ${busStopData.buses}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      calculateTime(busStopData.distance),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatDistance(busStopData.distance),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusStopSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Skeleton(
            height: 60,
            width: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                const SizedBox(height: 8),
                Skeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(
                height: 20,
                width: 70,
              ),
              const SizedBox(height: 8),
              Skeleton(
                height: 16,
                width: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSkeleton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(
            height: 200,
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                const SizedBox(height: 8),
                Skeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
                const SizedBox(height: 8),
                Skeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                const SizedBox(height: 8),
                Skeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
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

  Widget _buildInfoItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
