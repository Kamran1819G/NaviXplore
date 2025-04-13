import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Custom Interface
abstract class FirestoreProvider {
  Future<QuerySnapshot> getCollection(String collectionName);

  Future<DocumentSnapshot> getDocument(
      String collectionName, String documentName);
}

//Implementation class
class FirestoreProviderImpl implements FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<QuerySnapshot> getCollection(String collectionName) {
    return _firestore.collection(collectionName).get();
  }

  @override
  Future<DocumentSnapshot> getDocument(
      String collectionName, String documentName) {
    return _firestore.collection(collectionName).doc(documentName).get();
  }
}
abstract class LocalStorageProvider {
  Future<void> write(String key, dynamic value);
  dynamic read(String key);
}

class LocalStorageProviderImpl implements LocalStorageProvider{
  final GetStorage _storage = GetStorage();
  @override
  Future<void> write(String key, value) async{
    await  _storage.write(key, value);
  }

  @override
  read(String key) {
    return  _storage.read(key);
  }
}
class NMMetroController extends GetxController {
  final FirestoreProvider _firestoreProvider;
  final LocalStorageProvider _localStorageProvider;
  final _allMetroStations = <Map<String, dynamic>>[].obs;
  final _polylines = <dynamic>[].obs;
  final _distanceCache = <String, double>{}.obs;
  final _isLoading = false.obs;

  NMMetroController({
    FirestoreProvider? firestoreProvider,
    LocalStorageProvider? localStorageProvider,
  }):  _firestoreProvider = firestoreProvider ?? FirestoreProviderImpl(),
        _localStorageProvider = localStorageProvider ?? LocalStorageProviderImpl();


  List<Map<String, dynamic>> get allMetroStations => _allMetroStations;

  List<dynamic> get polylines => _polylines;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
    fetchData();
  }
  Future<void> fetchData() async{
    await fetchAllStations();
    await fetchPolylinePoints();
  }

  void _loadCachedData() {
    final cachedStations = _localStorageProvider.read('allMetroStations');
    final cachedPolylines = _localStorageProvider.read('polylines');

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
    _isLoading.value = true;
    try {
      QuerySnapshot querySnapshot =
      await _firestoreProvider.getCollection('NM-Metro-Stations');

      final stations = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      stations.sort((a, b) {
        int aNum = int.parse(
            a['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
        int bNum = int.parse(
            b['stationID'].replaceAll(RegExp(r'[^\d]+'), ''));
        return aNum.compareTo(bNum);
      });
      _allMetroStations.assignAll(stations);
      await  _localStorageProvider.write('allMetroStations', stations);
    } catch (e) {
      print('Error fetching metro stations: $e');
    }finally{
      _isLoading.value = false;
    }
  }

  Future<void> fetchPolylinePoints() async {
    if (_polylines.isNotEmpty) return;
    _isLoading.value = true;
    try {
      DocumentSnapshot snapshot = await _firestoreProvider.getDocument(
          'NM-Metro-Lines', 'jDEMGPW2mPiReUTrWs15');
      List<dynamic>? routeLineData =
      (snapshot.data() as Map<String, dynamic>)['polylines'];

      _polylines.assignAll(routeLineData ?? []);
      _localStorageProvider.write('polylines', routeLineData);
    } catch (e) {
      print('Error fetching polyline points: $e');
    }finally{
      _isLoading.value = false;
    }
  }

  double calculateTotalDistanceBetweenStations(
      int sourceStationID, int destinationStationID) {
    final key = '$sourceStationID-$destinationStationID';

    if (_distanceCache.containsKey(key)){
      return _distanceCache[key]!;
    }
    double totalDistance = 0.0;
    bool countingDistance = false;

    if (sourceStationID > destinationStationID) {
      for (var station in _allMetroStations.reversed) {
        int stationID = int.parse(
            station['stationID'].replaceAll(RegExp(r'[^0-9]'), ''));
        if (stationID == sourceStationID ||
            stationID == destinationStationID) {
          countingDistance = !countingDistance;
        }
        if (countingDistance) {
          totalDistance += station['distance']['fromPreviousStation'];
        }
        if (stationID == destinationStationID) break;
      }
    } else {
      for (var station in _allMetroStations) {
        int stationID = int.parse(
            station['stationID'].replaceAll(RegExp(r'[^0-9]'), ''));
        if (stationID == sourceStationID ||
            stationID == destinationStationID) {
          countingDistance = !countingDistance;
        }

        if (countingDistance) {
          totalDistance += station['distance']['toNextStation'];
        }

        if (stationID == destinationStationID) break;
      }
    }

    _distanceCache[key] = totalDistance;

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