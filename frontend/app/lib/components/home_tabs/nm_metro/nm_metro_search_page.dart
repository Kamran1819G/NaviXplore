import 'package:flutter/material.dart';
import 'package:navixplore/services/firestore_service.dart';
import 'nm_metro_upcoming_trains.dart';

class NMMetroSearchPage extends StatefulWidget {
  List<dynamic>? metroStationsList;

  NMMetroSearchPage({Key? key, required this.metroStationsList}) : super(key: key);

  @override
  State<NMMetroSearchPage> createState() => _NMMetroSearchPageState();
}

class _NMMetroSearchPageState extends State<NMMetroSearchPage> {
  List<dynamic>? metroStationsList;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize () async {
    await _fetchMetroStations();
  }

  Future<void> _fetchMetroStations() async{
    if(widget.metroStationsList != null){
      setState(() {
        metroStationsList = widget.metroStationsList;
      });
      return;
    }
    else {
      final metroStations = await FirestoreService().getCollection(
          collection: 'NM-Metro-Stations');
      metroStations.listen((event) {
        setState(() {
          metroStationsList = event.docs;
          metroStationsList?.sort((a, b) {
            // Extract numeric part from stationID (e.g., 'S001' -> 1)
            int aNum = int.parse(
                a.get('stationID').replaceAll(RegExp(r'[^\d]+'), ''));
            int bNum = int.parse(
                b.get('stationID').replaceAll(RegExp(r'[^\d]+'), ''));

            // Compare numeric parts
            return aNum.compareTo(bNum);
          });
        });
      });
    }
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
      body: Column(
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
              itemCount: metroStationsList!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NM_MetroUpcomingTrains(lineID: metroStationsList![index]["lineID"], stationID: metroStationsList![index]["stationID"], stationName: metroStationsList![index]["stationName"]["English"]),
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
                    metroStationsList![index]["stationName"]["English"],
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    metroStationsList![index]["stationName"]["Marathi"],
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
}
