import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:navixplore/core/services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  Rx<Position> currentLocation = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0, headingAccuracy: 0,
  )
      .obs; // Observable variable for current location
  var isLoading = false.obs; // Observable variable for loading state
  var errorMessage = ''.obs; // Observable variable for error messages
  bool _isFetching = false;
  // var locationUpdates = Rx<Position?>(null);
  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation({int retryCount = 0}) async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    isLoading.value = true; // Set loading to true while fetching location
    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        currentLocation.value = position;
      }else {
        errorMessage.value = 'Could not get location';
      }
    } on LocationServiceException catch (e) {
      errorMessage.value = e.message;
      if (retryCount < 3) {
        await Future.delayed(const Duration(seconds: 2));
        fetchCurrentLocation(retryCount: retryCount + 1);
      }
    } finally {
      _isFetching = false;
      isLoading.value = false; // Set loading to false after fetching location
    }
  }

//  void startLocationUpdates() {
//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     ).listen((event) {
//       locationUpdates.value = event;
//     });
//   }
//
//   @override
// void onClose() {
//     locationUpdates.value = null;
//     super.onClose();
//   }
}