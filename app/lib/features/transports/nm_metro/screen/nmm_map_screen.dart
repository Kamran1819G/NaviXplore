import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/features/transports/nm_metro/controller/nm_metro_controller.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class NMM_MapScreen extends StatefulWidget {
  NMM_MapScreen({Key? key}) : super(key: key);

  @override
  State<NMM_MapScreen> createState() => _NMM_MapScreenState();
}

class _NMM_MapScreenState extends State<NMM_MapScreen> {
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
    await controller.fetchPolylinePoints();
    await _addPolyline();
    setState(() {
      isLoading = false;
    });
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
                  color: Theme.of(context).primaryColor),
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.tram,
                color: Colors.white,
                size: 20,
              )),
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
                      const Text(
                        'Navi Mumbai Metro Stations',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.allMetroStations.length,
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
                              title: Text(controller.allMetroStations[index]
                                  ['stationName']['English']),
                              subtitle: Text(controller.allMetroStations[index]
                                  ['stationName']['Marathi']),
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
