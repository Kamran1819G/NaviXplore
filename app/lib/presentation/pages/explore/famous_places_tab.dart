import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/nm_places_controller.dart';
import 'package:navixplore/presentation/pages/explore/place_details_screen.dart';
import 'package:navixplore/presentation/widgets/image_container.dart';

import '../../widgets/Skeleton.dart';

class FamousPlacesTab extends StatelessWidget {
  const FamousPlacesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NMPlacesController controller = Get.find<NMPlacesController>();

    return Obx(() {
      if (controller.famousPlaces.isEmpty) {
        controller.fetchFamousPlaces();
        return ListView.separated(
          itemCount: 6,
          itemBuilder: (context, index) => placeSkeleton(context),
          separatorBuilder: (context, index) => const SizedBox(height: 20),
        );
      }

      return ListView.builder(
        itemCount: controller.famousPlaces.length,
        itemBuilder: (context, index) {
          final place = controller.famousPlaces[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailsScreen(place: place),
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
                    imageUrl: place['images'][0],
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(place['address']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget placeSkeleton(BuildContext context) {
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
