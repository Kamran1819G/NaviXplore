import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/config/api_endpoints.dart';

class NM_MetroMap extends StatefulWidget {
  final List<dynamic>? metroStationsList;

  NM_MetroMap({this.metroStationsList});

  @override
  State<NM_MetroMap> createState() => _NM_MetroMapState();
}

class _NM_MetroMapState extends State<NM_MetroMap> {
  List<dynamic>? metroStationsList;
  List<dynamic>? metroRouteLineDataList;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};
  final PanelController panelController = PanelController();
  bool isLoading = true;
  final Completer<GoogleMapController> _controller = Completer();
  late String _mapStyle;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _fetchMetroStations();
    _fetchPolylinePoints();
  }

  void _fetchMetroStations() async {
    if (widget.metroStationsList != null) {
      setState(() {
        metroStationsList = widget.metroStationsList;
        _addMetroStationMarker();
      });
    } else {
      final response =
          await http.get(Uri.parse(NM_MetroApiEndpoints.GetStations));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          metroStationsList = data;
          _addMetroStationMarker();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    }
  }

  void _fetchPolylinePoints() async {
    final response = await http.get(Uri.parse(
        NM_MetroApiEndpoints.GetlineData(metroStationsList![0]["lineID"])));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)["polylines"];
      setState(() {
        metroRouteLineDataList = data;
      });
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
    _addPolyline();
  }

  // Function to add polyline based on latitude and longitude points
  void _addPolyline() {
    List<LatLng> polylinePoints = [];

    // Convert latitude and longitude points to LatLng objects
    for (var point in metroRouteLineDataList!) {
      polylinePoints.add(LatLng(point['latitude'], point['longitude']));
    }

    // Add polyline to the map
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('polyline'),
          color: Colors.orange,
          points: polylinePoints,
          width: 3,
        ),
      );
    });
  }

  void _addMetroStationMarker() async {
    for (var station in metroStationsList!) {
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
          markerId: MarkerId(station['stationName']['English']),
          icon: markerBitmap,
          position: stationLatLng,
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
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
            body: GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(19.038901, 73.06716),
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                controller.setMapStyle(_mapStyle);
              },
              markers: markers,
              polylines: _polylines,
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
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const Text(
                  'Navi Mumbai Metro Stations',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: metroStationsList!.length,
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
                        title: Text(metroStationsList![index]['stationName']
                            ['English']),
                        subtitle: Text(metroStationsList![index]['stationName']
                            ['Marathi']),
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
              child: const CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.white,
                child: BackButton(
                  color: Colors.orange,
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
}
