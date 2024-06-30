import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';

class NMMTService {
  List<Map<String, dynamic>> allBusStops = [];
  List<Map<String, dynamic>> allBuses = [];

  Future<void> fetchAllStations() async {
    if (allBusStops.isNotEmpty) {
      return;
    }
    QuerySnapshot querySnapshot = await FirestoreService()
        .getCollection(collection: 'NMMT-Stations')
        .first;

    List<Map<String, dynamic>> stations = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    allBusStops = stations;
  }

  Future<void> fetchAllBuses() async {
    if (allBuses.isNotEmpty) {
      return;
    }
    QuerySnapshot querySnapshot =
        await FirestoreService().getCollection(collection: 'NMMT-Buses').first;

    List<Map<String, dynamic>> busStops = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    allBuses = busStops;
  }
}
