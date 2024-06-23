import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navixplore/widgets/image_container.dart';

class PlaceDetailScreen extends StatefulWidget {
  String placeName;
  String placeImageUrl;
  String placeLocation;
  String placeDescription;
  double placeLatitude;
  double placeLongitude;

  PlaceDetailScreen({super.key, required this.placeName, required this.placeImageUrl,required this.placeLocation, required this.placeDescription, required this.placeLatitude, required this.placeLongitude});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        elevation: 3,
        title:  const Row(
          children: [
            Text("Navi", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 20)),
            Text("X", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 25)),
            Text("plore", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 20)),
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
                  widget.placeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.bold,fontFamily: "Fredoka")
              ),
            ),
            SizedBox(height: 16),
            ImageContainer(
                height:MediaQuery.sizeOf(context).height * 0.3,
                width: MediaQuery.sizeOf(context).width * 0.95,
                imageUrl: widget.placeImageUrl,
            ),
            SizedBox(height: 10),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(widget.placeDescription, textAlign: TextAlign.justify)
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
                    target: LatLng(widget.placeLatitude, widget.placeLongitude),
                    zoom: 15,
                  ),
                  markers: <Marker>{
                    Marker(
                      markerId: MarkerId(widget.placeName),
                      position: LatLng(widget.placeLatitude, widget.placeLongitude),
                      infoWindow: InfoWindow(
                        title: widget.placeName,
                        snippet: widget.placeLocation,
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
