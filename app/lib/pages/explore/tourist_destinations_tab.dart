import 'package:flutter/material.dart';
import 'package:navixplore/pages/explore/place_detail_page.dart';
import 'package:navixplore/services/NM_Places_Service.dart';
import 'package:navixplore/widgets/image_container.dart';

import '../../widgets/Skeleton.dart';

class TouristDestinationsTab extends StatefulWidget {
  const TouristDestinationsTab({Key? key}) : super(key: key);

  @override
  State<TouristDestinationsTab> createState() => _TouristDestinationsTabState();
}

class _TouristDestinationsTabState extends State<TouristDestinationsTab> {
  bool isLoading = true;

  final NM_PlacesService nmPlacesService = NM_PlacesService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async{
    await nmPlacesService.fetchTouristPlaces();
    setState(() {
      isLoading = false;
    });
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
      itemCount: nmPlacesService.allTouristPlaces.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailPage(
                  place: nmPlacesService.allTouristPlaces[index],
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
                  imageUrl: nmPlacesService.allTouristPlaces[index]['images'][0],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nmPlacesService.allTouristPlaces[index]['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(nmPlacesService.allTouristPlaces[index]['address']),
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
