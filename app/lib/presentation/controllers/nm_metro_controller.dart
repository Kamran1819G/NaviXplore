import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NMMetroController extends GetxController {
  final _storage = GetStorage();
  final _allMetroStations = <Map<String, dynamic>>[].obs;
  final _polylines = <dynamic>[].obs;

  List<Map<String, dynamic>> get allMetroStations => _allMetroStations;
  List<dynamic> get polylines => _polylines;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  void _loadCachedData() {
    final cachedStations = _storage.read('allMetroStations');
    final cachedPolylines = _storage.read('polylines');

    if (cachedStations != null) {
      _allMetroStations
          .assignAll(List<Map<String, dynamic>>.from(cachedStations));
    }

    if (cachedPolylines != null) {
      _polylines.assignAll(List<dynamic>.from(cachedPolylines));
    }
  }

  Future<void> fetchAllStations() async {
    if (_allMetroStations.isNotEmpty) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NM-Metro-Stations')
          .get();

      List<Map<String, dynamic>> stations = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      stations.sort((a, b) {
        int aNum = int.parse(a['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
        int bNum = int.parse(b['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
        return aNum.compareTo(bNum);
      });

      _allMetroStations.assignAll(stations);
      _storage.write('allMetroStations', stations);
    } catch (e) {
      print('Error fetching metro stations: $e');
    }
  }

  Future<void> fetchPolylinePoints() async {
    if (_polylines.isNotEmpty) return;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('NM-Metro-Lines')
          .doc('jDEMGPW2mPiReUTrWs15')
          .get();

      List<dynamic>? routeLineData =
          (snapshot.data() as Map<String, dynamic>)['polylines'];

      _polylines.assignAll(routeLineData ?? []);
      _storage.write('polylines', routeLineData);
    } catch (e) {
      print('Error fetching polyline points: $e');
    }
  }

  double calculateTotalDistanceBetweenStations(
      int sourceStationID, int destinationStationID) {
    double totalDistance = 0.0;
    bool countingDistance = false;

    if (sourceStationID > destinationStationID) {
      for (var station in _allMetroStations.reversed) {
        int stationID =
            int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), ''));
        if (stationID == sourceStationID || stationID == destinationStationID) {
          countingDistance = !countingDistance;
        }

        if (countingDistance) {
          totalDistance += station['distance']['fromPreviousStation'];
        }

        if (stationID == destinationStationID) break;
      }
    } else {
      for (var station in _allMetroStations) {
        int stationID =
            int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), ''));
        if (stationID == sourceStationID || stationID == destinationStationID) {
          countingDistance = !countingDistance;
        }

        if (countingDistance) {
          totalDistance += station['distance']['toNextStation'];
        }

        if (stationID == destinationStationID) break;
      }
    }

    return totalDistance;
  }

  double calculateFare(double distance) {
    if (distance <= 2) return 10;
    if (distance <= 4) return 10;
    if (distance <= 6) return 20;
    if (distance <= 8) return 20;
    if (distance <= 10) return 30;
    return 30;
  }
}
