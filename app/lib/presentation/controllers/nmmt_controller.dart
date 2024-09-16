import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    allBusStops.value = _storage.read('allBusStops') ?? [];
    allBuses.value = _storage.read('allBuses') ?? [];
    announcements.value = _storage.read('announcements') ?? [];
  }

  Future<void> fetchAllStations() async {
    if (allBusStops.isNotEmpty) return;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('NMMT-Stations').get();
    allBusStops.value = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    _storage.write('allBusStops', allBusStops);
  }

  Future<void> fetchAllBuses() async {
    if (allBuses.isNotEmpty) return;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('NMMT-Buses').get();
    allBuses.value = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    _storage.write('allBuses', allBuses);
  }

  Future<void> fetchAnnouncements() async {
    if (announcements.isNotEmpty) return;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('NMMT-Announcements')
        .orderBy('releaseAt', descending: true)
        .get();
    announcements.value = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    _storage.write('announcements', announcements);
  }
}
