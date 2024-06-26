import 'package:flutter/material.dart';
import 'package:navixplore/services/NM_Metro_Service.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';
import 'package:navixplore/widgets/Skeleton.dart';
import 'nm_metro_upcoming_trains.dart';

class NMMetroSearchPage extends StatefulWidget {
  NMMetroSearchPage({Key? key}) : super(key: key);

  @override
  State<NMMetroSearchPage> createState() => _NMMetroSearchPageState();
}

class _NMMetroSearchPageState extends State<NMMetroSearchPage> {
  bool isLoading = true;

  final NM_MetroService _nmMetroService = NM_MetroService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await _nmMetroService.fetchAllStations();
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
                    color: Colors.orange,
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
                    itemCount: _nmMetroService.allMetroStations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NM_MetroUpcomingTrains(
                                  lineID: _nmMetroService
                                      .allMetroStations[index]["lineID"],
                                  stationID: _nmMetroService
                                      .allMetroStations[index]["stationID"],
                                  stationName:
                                      _nmMetroService.allMetroStations[index]
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
                          _nmMetroService.allMetroStations[index]["stationName"]
                              ["English"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _nmMetroService.allMetroStations[index]["stationName"]
                              ["Marathi"],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange,
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
