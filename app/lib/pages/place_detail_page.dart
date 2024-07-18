import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navixplore/widgets/image_container.dart';

class PlaceDetailPage extends StatefulWidget {
  final Map<String, dynamic> place;


  PlaceDetailPage({required this.place});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 3,
        title:  Row(
          children: [
            Text("Navi", style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 20)),
            Text("X", style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 25)),
            Text("plore", style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Text(
                  widget.place['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30, fontWeight: FontWeight.bold,fontFamily: "Fredoka")
              ),
            ),
            SizedBox(height: 16),
            ImageContainer(
                height:MediaQuery.sizeOf(context).height * 0.3,
                width: MediaQuery.sizeOf(context).width * 0.95,
                imageUrl: widget.place['images'][0],
            ),
            SizedBox(height: 10),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(widget.place['description'], textAlign: TextAlign.justify)
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 300,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                    fortyFiveDegreeImageryEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.place['location']['latitude'], widget.place['location']['longitude']),
                    zoom: 15,
                  ),
                  markers: <Marker>{
                    Marker(
                      markerId: MarkerId(widget.place['name']),
                      position: LatLng(widget.place['location']['latitude'], widget.place['location']['longitude']),
                      infoWindow: InfoWindow(
                        title: widget.place['name'],
                        snippet: widget.place['address'],
                      ),
                    ),
                }
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
