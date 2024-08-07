import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navixplore/core/services/location_service.dart';

class LocationViewModel extends GetxController {
  var currentLocation =
      Rx<Position?>(null); // Observable variable for current location
  var isLoading = true.obs; // Observable variable for loading state
  final LocationService _locationService = LocationService();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLoading.value = true; // Set loading to true while fetching location
      Position position = await _locationService.getCurrentLocation();
      currentLocation.value =
          position; // Update currentLocation with fetched position
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      isLoading.value = false; // Set loading to false after fetching location
    }
  }
}
