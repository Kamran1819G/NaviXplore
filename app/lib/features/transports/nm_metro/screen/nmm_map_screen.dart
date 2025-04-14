import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/features/transports/nm_metro/controller/nm_metro_controller.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart'; // Consider removing this dependency for performance

class NMM_MapScreen extends StatefulWidget {
  const NMM_MapScreen({super.key});

  @override
  State<NMM_MapScreen> createState() => _NMM_MapScreenState();
}

class _NMM_MapScreenState extends State<NMM_MapScreen> {
  List<Marker> markers = [];
  final List<Polyline> _polylines = [];
  final PanelController panelController = PanelController();
  final MapController mapController = MapController();
  // String _mapStyle; // Removed unused variable
  bool isLoading = true;
  String? errorMessage; // To handle error messages during loading

  final NMMetroController controller = Get.find<NMMetroController>();

  @override
  void initState() {
    super.initState();
    initializeMapData(); // Renamed initialize to initializeMapData for clarity
  }

  Future<void> initializeMapData() async {
    try {
      // Removed map style loading as it wasn't used and simplified initialization
      // await rootBundle.loadString('assets/map_style.txt').then((string) {
      //   _mapStyle = string;
      // });
      await controller.fetchAllStations();
      await _addMetroStationMarkers(); // Renamed to plural Markers
      await controller.fetchPolylinePoints();
      await _addPolyline();
    } catch (e) {
      // Basic error handling, improve as needed (e.g., show dialog)
      errorMessage = 'Failed to load map data. Please check your connection and try again.';
      debugPrint('Error loading map data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addPolyline() async {
    if (controller.polylines.isEmpty) return; // Prevent error if no polyline data

    List<LatLng> polylinePoints = controller.polylines.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

    _polylines.add(
      Polyline(
        points: polylinePoints,
        color: Theme.of(context).primaryColor,
        strokeWidth: 3,
      ),
    );
    // setState is now called in initializeMapData's finally block after all data is processed.
  }

  Future<void> _addMetroStationMarkers() async {
    if (controller.allMetroStations.isEmpty) return; // Prevent error if no station data

    List<Marker> newMarkers = []; // Create a new list to batch updates
    for (var station in controller.allMetroStations) {
      // Optimized marker creation - using Icon instead of Widget to Bitmap conversion for performance
      LatLng stationLatLng = LatLng(
          station['location']['latitude'], station['location']['longitude']);

      newMarkers.add(
        Marker(
          point: stationLatLng,
          width: 30,
          height: 30,
          child: GestureDetector( // Added GestureDetector for potential marker interactions in future
            onTap: () {
              // Handle marker tap if needed, e.g., show station details
              debugPrint('Station tapped: ${station['stationName']['English']}');
              // Example: You can use panelController to show station details in the sliding panel
              panelController.open(); // Example - opens the panel on marker tap
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.all(4),
                child: const Icon( // Using const Icon for optimization
                  Icons.tram,
                  color: Colors.white,
                  size: 20,
                )),
          ),
        ),
      );
    }
    markers = newMarkers; // Update markers list
    // setState is now called in initializeMapData's finally block after all data is processed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
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
          : errorMessage != null // Show error message if loading failed
          ? _buildErrorScreen()
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
            panel: _buildStationPanel(), // Extracted panel widget
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

  Widget _buildStationPanel() {
    return Column(
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
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const Text(
          'Navi Mumbai Metro Stations',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: controller.allMetroStations.length,
            itemBuilder: (context, index) {
              final station = controller.allMetroStations[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(10.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/icons/NM_Metro.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline), // Basic error handling for image loading
                  ),
                ),
                title: Text(station['stationName']['English'] ?? 'Station Name'), // Null safety
                subtitle: Text(station['stationName']['Marathi'] ?? ''), // Null safety
              );
            },
          ),
        ),
      ],
    );
  }

  // Removed metroStationMarker widget as it's no longer used.
  // Widget metroStationMarker(String stationName) { ... }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mapSkeleton(
            height: 300, // Reduced height for loading skeleton
            width: MediaQuery.of(context).size.width,
          ),
          const SizedBox(height: 20),
          Expanded( // Using Expanded to allow list to take available space
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile( // Using const ListTile as content is skeleton
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

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null; // Clear error message
                });
                initializeMapData(); // Retry loading
              },
              child: const Text('Retry'),
            ),
          ],
        ),
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