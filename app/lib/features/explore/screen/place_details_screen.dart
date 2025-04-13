import 'package:flutter/material.dart';
import 'package:navixplore/features/widgets/image_container.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  PlaceDetailsScreen({required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 3,
        title: Row(
          children: [
            Text("Navi",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text("X",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
            Text("plore",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
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
              child: Text(widget.place['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Fredoka")),
            ),
            SizedBox(height: 16),
            ImageContainer(
              height: MediaQuery.sizeOf(context).height * 0.3,
              width: MediaQuery.sizeOf(context).width * 0.95,
              imageUrl: widget.place['images'][0],
            ),
            SizedBox(height: 10),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(widget.place['description'],
                    textAlign: TextAlign.justify)),
            Card(
              elevation: 3,
              margin: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(widget.place['location']['latitude'],
                        widget.place['location']['longitude']),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                            point: LatLng(widget.place['location']['latitude'],
                                widget.place['location']['longitude']),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
