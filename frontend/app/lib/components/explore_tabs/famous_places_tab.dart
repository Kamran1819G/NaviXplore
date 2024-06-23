import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/components/explore_tabs/place_detail_screen.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:navixplore/widgets/image_container.dart';
import '../../widgets/Skeleton.dart';

class FamousPlacesTab extends StatefulWidget {
  const FamousPlacesTab({Key? key}) : super(key: key);

  @override
  State<FamousPlacesTab> createState() => _FamousPlacesTabState();
}

class _FamousPlacesTabState extends State<FamousPlacesTab> {
  List<Map<String, dynamic>> famousplaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(PlacesApiEndpoints.FamousPlaces));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          famousplaces = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        // Handle non-200 status codes
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
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
            itemCount: famousplaces.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailScreen(
                        placeName: famousplaces[index]['name'],
                        placeImageUrl: famousplaces[index]['image_url'],
                        placeLocation: famousplaces[index]['location'],
                        placeDescription: famousplaces[index]['content'],
                        placeLatitude: famousplaces[index]['coordinates']['latitude'],
                        placeLongitude: famousplaces[index]['coordinates']['longitude'],
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
                        imageUrl: famousplaces[index]['image_url'],
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              famousplaces[index]['name'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(famousplaces[index]['location']),
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
