import 'package:flutter/material.dart';
import 'package:navixplore/components/explore_tabs/place_detail_screen.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:navixplore/widgets/image_container.dart';
import 'package:navixplore/widgets/webview_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widgets/Skeleton.dart';

class TouristDestinationsTab extends StatefulWidget {
  const TouristDestinationsTab({Key? key}) : super(key: key);

  @override
  State<TouristDestinationsTab> createState() => _TouristDestinationsTabState();
}

class _TouristDestinationsTabState extends State<TouristDestinationsTab> {
  List<Map<String, dynamic>> touristplaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
      // Show a loading indicator
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(PlacesApiEndpoints.TouristDestinations));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          touristplaces = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        // Handle non-200 status codes
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? ListView.separated(
      itemCount: 6,
      itemBuilder: (context, index) => placeSkeleton(),
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    )
        : ListView.builder(
      itemCount: touristplaces.length,
      itemBuilder: (context, index) {
        String baseUrl = 'https://navixplore.vercel.app/places/';
        String placeName = touristplaces[index]['name'];
        String placeurl = '$baseUrl$placeName';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailScreen(
                  placeName: touristplaces[index]['name'],
                  placeImageUrl: touristplaces[index]['image_url'],
                  placeLocation: touristplaces[index]['location'],
                  placeDescription: touristplaces[index]['content'],
                  placeLatitude: touristplaces[index]['coordinates']['latitude'],
                  placeLongitude: touristplaces[index]['coordinates']['longitude'],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ImageContainer(
                  height: 125,
                  width: 125,
                  imageUrl: touristplaces[index]['image_url'],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        touristplaces[index]['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(touristplaces[index]['location']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget placeSkeleton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(
              height: MediaQuery.of(context).size.width * 0.3,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Skeleton(
                  height: MediaQuery.of(context).size.width * 0.15,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                SizedBox(height: 5),
                Skeleton(
                  height: MediaQuery.of(context).size.width * 0.05,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
