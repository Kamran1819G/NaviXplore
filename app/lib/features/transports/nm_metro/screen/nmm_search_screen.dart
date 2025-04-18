import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navixplore/features/transports/nm_metro/controller/nm_metro_controller.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';

import 'nmm_upcoming_trains_screen.dart';

class NMM_SearchPageScreen extends StatefulWidget {
  NMM_SearchPageScreen({Key? key}) : super(key: key);

  @override
  State<NMM_SearchPageScreen> createState() => _NMM_SearchPageScreenState();
}

class _NMM_SearchPageScreenState extends State<NMM_SearchPageScreen> {
  bool isLoading = true;

  final NMMetroController controller = Get.find<NMMetroController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await controller.fetchAllStations();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: Text(
            "You are at  ?",
            style: TextStyle(color: Colors.black),
          )),
      body: isLoading
          ? _buildSkeleton()
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Discover the city with ease! Plan your metro journey and unlock the best routes and schedules for a seamless travel experience.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.allMetroStations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NMM_UpcomingTrainsScreen(
                                  lineID: controller.allMetroStations[index]
                                      ["lineID"],
                                  stationID: controller.allMetroStations[index]
                                      ["stationID"],
                                  stationName:
                                      controller.allMetroStations[index]
                                          ["stationName"]["English"]),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/icons/NM_Metro.png',
                            width: 50,
                            height: 50,
                          ),
                        ),
                        title: Text(
                          controller.allMetroStations[index]["stationName"]
                              ["English"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          controller.allMetroStations[index]["stationName"]
                              ["Marathi"],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Skeleton(height: 50, width: 50),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Skeleton(height: 8, width: 100),
          ),
          subtitle: Skeleton(height: 8, width: 50),
        );
      },
    );
  }
}
