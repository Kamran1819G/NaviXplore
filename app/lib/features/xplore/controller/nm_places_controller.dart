import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NMPlacesController extends GetxController {
  final _storage = GetStorage();
  final _allPlaces = <Map<String, dynamic>>[].obs;
  final _famousPlaces = <Map<String, dynamic>>[].obs;
  final _touristPlaces = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get allPlaces => _allPlaces;

  List<Map<String, dynamic>> get famousPlaces => _famousPlaces;

  List<Map<String, dynamic>> get touristPlaces => _touristPlaces;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  void _loadCachedData() {
    final cachedAllPlaces = _storage.read('allPlaces');
    if (cachedAllPlaces != null) {
      _allPlaces.assignAll(List<Map<String, dynamic>>.from(cachedAllPlaces));
    }
    final cachedFamousPlaces = _storage.read('famousPlaces');
    if (cachedFamousPlaces != null) {
      _famousPlaces
          .assignAll(List<Map<String, dynamic>>.from(cachedFamousPlaces));
    }
    final cachedTouristPlaces = _storage.read('touristPlaces');
    if (cachedTouristPlaces != null) {
      _touristPlaces
          .assignAll(List<Map<String, dynamic>>.from(cachedTouristPlaces));
    }
  }

  Future<void> fetchAllPlaces() async {
    if (_allPlaces.isNotEmpty) return;
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('NM-Places').get();
      final places = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _allPlaces.assignAll(places);
      _storage.write('allPlaces', places);
    } catch (e) {
      print('Error fetching all places: $e');
    }
  }

  Future<void> fetchFamousPlaces() async {
    if (_famousPlaces.isNotEmpty) return;
    await fetchAllPlaces();
    final famous = _allPlaces.where((place) {
      List<dynamic> tags = place['tags'] ?? [];
      return tags.contains('Famous Places');
    }).toList();
    _famousPlaces.assignAll(famous);
    _storage.write('famousPlaces', famous);
  }

  Future<void> fetchTouristPlaces() async {
    if (_touristPlaces.isNotEmpty) return;
    await fetchAllPlaces();
    final tourist = _allPlaces.where((place) {
      List<dynamic> tags = place['tags'] ?? [];
      return tags.contains('Tourist Destination');
    }).toList();
    _touristPlaces.assignAll(tourist);
    _storage.write('touristPlaces', tourist);
  }

  Future<void> refreshAllData() async {
    _allPlaces.clear();
    _famousPlaces.clear();
    _touristPlaces.clear();
    _storage.erase();
    await fetchAllPlaces();
    await fetchFamousPlaces();
    await fetchTouristPlaces();
  }
}
