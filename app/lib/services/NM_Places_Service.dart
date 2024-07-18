import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase/firestore_service.dart';

class NM_PlacesService {
  List<Map<String, dynamic>> allPlaces = [];
  List<Map<String, dynamic>> allFamousPlaces = [];
  List<Map<String, dynamic>> allTouristPlaces = [];

  Future<void> fetchAllPlaces() async {
    if (allPlaces.isNotEmpty) {
      return;
    }
    QuerySnapshot querySnapshot = await FirestoreService()
        .getCollection(collection: 'NM-Places')
        .first;

    allPlaces = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> fetchFamousPlaces() async {
    if (allFamousPlaces.isNotEmpty) {
      return;
    }
    await fetchAllPlaces();

    allFamousPlaces = allPlaces.where((place) {
      List<dynamic> tags = place['tags'] ?? [];
      return tags.contains('Famous Places');
    }).toList();
  }

  Future<void> fetchTouristPlaces() async {
    if (allTouristPlaces.isNotEmpty) {
      return;
    }
    await fetchAllPlaces();

    allTouristPlaces = allPlaces.where((place) {
      List<dynamic> tags = place['tags'] ?? [];
      return tags.contains('Tourist Destination');
    }).toList();
  }
}