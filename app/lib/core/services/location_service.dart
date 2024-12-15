import 'package:geolocator/geolocator.dart';

// Custom Exception Class
class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() {
    return 'LocationServiceException: $message';
  }
}

//Custom Interface
abstract class LocationProvider {
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
  });

  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

// Implementation class
class GeolocatorProvider implements LocationProvider {
  @override
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      return null; // return null instead of throwing error
    }
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }
}

class LocationService {
  final LocationProvider _locationProvider;
  Position? _cachedPosition;
  DateTime? _cacheTime;
  final Duration _cacheDuration;

  LocationService(
      {
        LocationProvider? locationProvider,
        Duration? cacheDuration,
      }
      ): _locationProvider = locationProvider ?? GeolocatorProvider(),
        _cacheDuration = cacheDuration ?? const Duration(minutes: 2);

  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.best,
    bool useCache = true,
  }) async {
    // Check if there is cached data
    if(useCache && _cachedPosition != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration){
      return _cachedPosition;
    }
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled.');
    }

    permission = await _locationProvider.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationProvider.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    final position = await _locationProvider.getCurrentPosition(accuracy: accuracy);

    if(position != null){
      _cachedPosition = position;
      _cacheTime = DateTime.now();
    }

    return position;
  }
}