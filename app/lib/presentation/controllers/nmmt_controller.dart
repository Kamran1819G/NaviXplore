import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NMMTController extends GetxController {
  final _storage = GetStorage();
  RxList<Map<String, dynamic>> allBusStops = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allBuses = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> announcements = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    // Read data as List<Map<String, dynamic>> or null.
    final List<dynamic>? storedBusStops = _storage.read('allBusStops');
    final List<dynamic>? storedBuses = _storage.read('allBuses');
    final List<dynamic>? storedAnnouncements = _storage.read('announcements');
    // Cast the dynamic lists to the correct type
    allBusStops.value = (storedBusStops?.cast<Map<String, dynamic>>()) ?? [];
    allBuses.value = (storedBuses?.cast<Map<String, dynamic>>()) ?? [];
    announcements.value = (storedAnnouncements?.cast<Map<String, dynamic>>()) ?? [];
  }

  Future<void> fetchAllStations() async {
    if (allBusStops.isNotEmpty) return;
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('NMMT-Stations').get();
    final List<Map<String, dynamic>> fetchedStops = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    allBusStops.value = fetchedStops;
    _storage.write('allBusStops', fetchedStops); // Write the raw List
  }

  Future<void> fetchAllBuses() async {
    if (allBuses.isNotEmpty) return;
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('NMMT-Buses').get();
    final List<Map<String, dynamic>> fetchedBuses = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    allBuses.value = fetchedBuses;
    _storage.write('allBuses', fetchedBuses); // Write the raw List
  }

  Future<void> fetchAnnouncements() async {
    if (announcements.isNotEmpty) return;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('NMMT-Announcements')
        .orderBy('releaseAt', descending: true)
        .get();
    final List<Map<String, dynamic>> fetchedAnnouncements = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    announcements.value = fetchedAnnouncements;
    _storage.write('announcements', fetchedAnnouncements); // Write the raw List
  }
}