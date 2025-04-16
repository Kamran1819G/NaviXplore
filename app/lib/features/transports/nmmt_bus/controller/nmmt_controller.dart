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
    announcements.value =
        (storedAnnouncements?.cast<Map<String, dynamic>>()) ?? [];
  }

  Future<void> fetchAllStations() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('NMMT-Stations').get();
      final List<Map<String, dynamic>> fetchedStops = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      allBusStops.value = fetchedStops;
      await _storage.write('allBusStops', fetchedStops); // Write the raw List
    } catch (e) {
      print('Error fetching stations: $e'); // Log the error
      // Optionally, re-throw the error or handle it as needed.
      // For now, just logging and letting the UI handle empty list if fetch fails.
    }
  }

  Future<void> fetchAllBuses() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('NMMT-Buses').get();
      final List<Map<String, dynamic>> fetchedBuses = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      allBuses.value = fetchedBuses;
      await _storage.write('allBuses', fetchedBuses); // Write the raw List
    } catch (e) {
      print('Error fetching buses: $e'); // Log the error
      // Optionally, re-throw the error or handle it as needed.
    }
  }

  Future<void> fetchAnnouncements() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NMMT-Announcements')
          .orderBy('releaseAt', descending: true)
          .get();
      final List<Map<String, dynamic>> fetchedAnnouncements = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      announcements.value = fetchedAnnouncements;
      await _storage.write('announcements', fetchedAnnouncements); // Write the raw List
    } catch (e) {
      print('Error fetching announcements: $e'); // Log the error
      // Optionally, re-throw the error or handle it as needed.
    }
  }

  // Function to refresh all data from Firebase
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchAllStations(),
      fetchAllBuses(),
      fetchAnnouncements(),
    ]);
  }

  // Function to clear local storage and then load from storage (effectively refreshing from Firebase on next fetch)
  Future<void> clearAndRefreshData() async {
    await _storage.remove('allBusStops');
    await _storage.remove('allBuses');
    await _storage.remove('announcements');
    allBusStops.value = []; // Clear RxList values to trigger refetch in UI if needed
    allBuses.value = [];
    announcements.value = [];
    await refreshAllData(); // Immediately fetch fresh data after clearing storage
    _loadFromStorage(); // Reload from storage (which now should have the refreshed data)
  }
}