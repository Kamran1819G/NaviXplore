import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/transports/nm_metro/controller/nm_metro_controller.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_fare_calculator_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_map_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_penalties_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_search_screen.dart';
import 'package:navixplore/features/transports/nm_metro/screen/nmm_upcoming_trains_screen.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';

enum IconType { icon, asset }

class NMM_Tab extends StatefulWidget {
  const NMM_Tab({Key? key}) : super(key: key);

  @override
  State<NMM_Tab> createState() => _NMM_TabState();
}

class _NMM_TabState extends State<NMM_Tab> {
  bool isLoading = true;
  late double? _currentLatitude;
  late double? _currentlongitude;
  List<dynamic>? nearestStationsList;

  final NMMetroController _controller = Get.put(NMMetroController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initialize() async {
    await _getCurrentLocation();
    await _controller.fetchAllStations();
    await fetchNearestStations();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLatitude = position.latitude;
      _currentlongitude = position.longitude;
    });
  }

  Future<void> fetchNearestStations() async {
    if (_currentLatitude == null || _currentlongitude == null) {
      return;
    }

    List<Map<String, dynamic>> stationsWithDistance = [];

    for (var station in _controller.allMetroStations) {
      double stationLat = station['location']['latitude'];
      double stationLon = station['location']['longitude'];

      double distance = Geolocator.distanceBetween(
          _currentLatitude!, _currentlongitude!, stationLat, stationLon);

      stationsWithDistance.add({
        'stationID': station['stationID'],
        'lineID': station['lineID'],
        'stationName': station['stationName'],
        'location': station['location'],
        'distance': distance,
      });
    }

    // Sort stations by distance
    stationsWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      nearestStationsList = stationsWithDistance;
      isLoading = false;
    });
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(2)} km';
    } else {
      return '${distanceInMeters.round()} m';
    }
  }

  String calculateTime(double distanceInMeters) {
    // Average walking speed: 5 km/h (0.0833 km/min)
    double distanceInKm = distanceInMeters / 1000;
    double timeInMinutes = distanceInKm / 0.0833;

    if (timeInMinutes < 1) {
      return '1 min';
    } else if (timeInMinutes < 60) {
      return '${timeInMinutes.toStringAsFixed(0)} min';
    } else {
      double timeInHours = timeInMinutes / 60;
      return '${timeInHours.toStringAsFixed(1)} hr';
    }
  }

  Future<void> _handleNavigationTap(Widget screen) async {
    _navigateToScreen(screen);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _handleNavigationTap(NMM_SearchPageScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          "assets/icons/NM_Metro.png",
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
                              "You are at",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 24,
                              child: AnimatedTextKit(
                                repeatForever: true,
                                pause: const Duration(milliseconds: 150),
                                animatedTexts: _controller.allMetroStations.isNotEmpty
                                    ? [
                                  for (var station in _controller.allMetroStations)
                                    TyperAnimatedText(
                                      station["stationName"]["English"],
                                      textStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      speed: const Duration(milliseconds: 80),
                                    ),
                                ]
                                    : [
                                  TyperAnimatedText(
                                    "Loading...",
                                    textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                ],
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

            // Nearest Metro Station
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, "Nearest Metro Station"),

                  const SizedBox(height: 12),

                  isLoading
                      ? _buildLoadingSkeleton(context)
                      : _buildNearestStationCard(context),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Metro Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, "Metro Services"),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildServiceCard(
                        context: context,
                        title: "Fare",
                        icon: Icons.currency_rupee_rounded,
                        iconType: IconType.icon,
                        color: Colors.blue.shade700,
                        onTap: () => _handleNavigationTap(NMM_FareCalculatorScreen()),
                      ),
                      _buildServiceCard(
                        context: context,
                        title: "Penalties",
                        icon: "assets/images/Law.png",
                        iconType: IconType.asset,
                        color: Colors.red.shade700,
                        onTap: () => _handleNavigationTap(const NMM_PenaltiesScreen()),
                      ),
                      _buildServiceCard(
                        context: context,
                        title: "Map",
                        icon: "assets/images/Map.png",
                        iconType: IconType.asset,
                        color: Colors.green.shade700,
                        onTap: () => _handleNavigationTap(NMM_MapScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Metro Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, "Metro Information"),

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
                          title: "Station Facilities",
                          icon: Icons.accessibility_new_rounded,
                          onTap: () {
                            // Navigate to station facilities page
                          },
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          context: context,
                          title: "Metro Rules",
                          icon: Icons.rule_rounded,
                          onTap: () {
                            // Navigate to metro rules page
                          },
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          context: context,
                          title: "Working Hours",
                          icon: Icons.access_time_rounded,
                          onTap: () {
                            // Navigate to working hours page
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
    );
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

  Widget _buildNearestStationCard(BuildContext context) {
    if (nearestStationsList == null || nearestStationsList!.isEmpty) {
      return _buildNoStationsCard();
    }

    final station = nearestStationsList![0];
    final distance = station["distance"];
    final travelTime = calculateTime(distance);
    final formattedDistance = formatDistance(distance);

    return GestureDetector(
      onTap: () => _handleNavigationTap(
        NMM_UpcomingTrainsScreen(
          lineID: station["lineID"],
          stationID: station["stationID"],
          stationName: station["stationName"]["English"],
        ),
      ),
      child: Container(
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
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/icons/NM_Metro.png',
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station["stationName"]["English"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station["stationName"]["Marathi"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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
                      travelTime,
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
                  formattedDistance,
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
            child: Text(
              "No nearby stations found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
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

  Widget _buildServiceCard({
  required BuildContext context,
  required String title,
  required dynamic icon,
  required IconType iconType,
  required Color color,
  required VoidCallback onTap,
  }) {
  return GestureDetector(
  onTap: onTap,
  child: Container(
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
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
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
  color: color.withOpacity(0.1),
  borderRadius: BorderRadius.circular(16),
  ),
  child: iconType == IconType.icon
  ? Icon(icon, size: 32, color: color)
      : Image.asset(icon, height: 32, width: 32),
  ),
  const SizedBox(height: 12),
  Text(
  title,
  textAlign: TextAlign.center,
  style: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.grey.shade800,
  ),
  ),
  ],
  ),
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

  Widget _buildDivider() {
  return Divider(
  height: 1,
  thickness: 1,
  color: Colors.grey.shade200,
  indent: 16,
  endIndent: 16,
  );
  }
}