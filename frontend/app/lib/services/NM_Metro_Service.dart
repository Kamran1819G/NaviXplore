import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';

class NM_MetroService {
  List<Map<String, dynamic>> allMetroStations = [];
  List<dynamic> polylines = [];

  Future<void> fetchAllStations() async {
    if (allMetroStations.isNotEmpty) {
      return;
    }

    QuerySnapshot querySnapshot =
    await FirestoreService().getCollection(collection: 'NM-Metro-Stations').first;

    List<Map<String, dynamic>> stations = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    stations.sort((a, b) {
      int aNum = int.parse(a['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
      int bNum = int.parse(b['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
      return aNum.compareTo(bNum);
    });

    allMetroStations = stations;
  }

  Future<void> fetchPolylinePoints() async {
    if (polylines.isNotEmpty) {
      return;
    }

    DocumentSnapshot snapshot = await FirestoreService().getDocument(
      collection: 'NM-Metro-Lines',
      docId: 'jDEMGPW2mPiReUTrWs15',
    );

    List<dynamic>? routeLineData = (snapshot.data() as Map<String, dynamic>)['polylines'];

    polylines = routeLineData!;
  }
}
