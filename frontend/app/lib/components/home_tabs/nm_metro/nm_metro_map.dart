import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';

class NM_MetroMap extends StatefulWidget {
  List<dynamic>? metroStationsList;

  NM_MetroMap({Key? key, this.metroStationsList}) : super(key: key);

  @override
  State<NM_MetroMap> createState() => _NM_MetroMapState();
}

class _NM_MetroMapState extends State<NM_MetroMap> {
  List<dynamic>? metroStationsList;
  List<dynamic> metroRouteLineDataList= [];
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};
  final PanelController panelController = PanelController();
  final Completer<GoogleMapController> _controller = Completer();
  late String _mapStyle;


  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize ()async{
    await rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    await _fetchMetroStations();
  }

  Future<void> _fetchMetroStations() async{
    if(widget.metroStationsList != null){
      setState(() {
        metroStationsList = widget.metroStationsList;
      });
      _addMetroStationMarker();
      if (metroStationsList!.isNotEmpty) {
        _fetchPolylinePoints();
      }
      return;
    }
    else {
      final metroStations = await FirestoreService().getCollection(
          collection: 'NM-Metro-Stations');
      metroStations.listen((event) {
        setState(() {
          metroStationsList = event.docs;
          metroStationsList?.sort((a, b) {
            // Extract numeric part from stationID (e.g., 'S001' -> 1)
            int aNum = int.parse(
                a.get('stationID').replaceAll(RegExp(r'[^\d]+'), ''));
            int bNum = int.parse(
                b.get('stationID').replaceAll(RegExp(r'[^\d]+'), ''));

            // Compare numeric parts
            return aNum.compareTo(bNum);
          });
          _addMetroStationMarker();
          _fetchPolylinePoints();
        });
      });
    }
  }

  Future<void> _fetchPolylinePoints() async {
    try {
      final DocumentSnapshot snapshot = await FirestoreService().getDocument(
        collection: 'NM-Metro-Lines',
        docId: 'jDEMGPW2mPiReUTrWs15',
      );
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> routeLineData = data['polylines'];

      setState(() {
        metroRouteLineDataList = routeLineData;
        _addPolyline();
      });
    } catch (e) {
      print('Error fetching polyline points: $e');
    }
  }


  void _addPolyline() {
    List<LatLng> polylinePoints = metroRouteLineDataList.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

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


  Future<void> _addMetroStationMarker() async {
    for (var station in metroStationsList!) {
      final markerBitmap =
          await metroStationMarker(station['stationName']['English'])
              .toBitmapDescriptor(
        logicalSize: const Size(500, 250),
        imageSize: const Size(500, 250),
      );

      // Create a LatLng object
      LatLng stationLatLng = LatLng(
          station['location']['_latitude'], station['location']['_longitude']);

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
