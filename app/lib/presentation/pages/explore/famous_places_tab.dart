import 'package:flutter/material.dart';
import 'package:navixplore/presentation/pages/explore/place_details_screen.dart';
import 'package:navixplore/presentation/widgets/image_container.dart';
import 'package:navixplore/services/NM_Places_Service.dart';
import '../../widgets/Skeleton.dart';

class FamousPlacesTab extends StatefulWidget {
  const FamousPlacesTab({Key? key}) : super(key: key);

  @override
  State<FamousPlacesTab> createState() => _FamousPlacesTabState();
}

class _FamousPlacesTabState extends State<FamousPlacesTab> {
  bool isLoading = true;

  final NM_PlacesService nmPlacesService = NM_PlacesService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await nmPlacesService.fetchFamousPlaces();
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
            itemCount: nmPlacesService.allFamousPlaces.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(
                        place: nmPlacesService.allFamousPlaces[index],
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
                        imageUrl: nmPlacesService.allFamousPlaces[index]
                            ['images'][0],
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nmPlacesService.allFamousPlaces[index]['name'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(nmPlacesService.allFamousPlaces[index]
                                ['address']),
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
