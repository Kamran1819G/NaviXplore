import 'dart:math';

class GeoCalculator {
  final double earthRadius;

  GeoCalculator({this.earthRadius = 6371.0});

  /// Calculates the distance between two geographical coordinates using the Haversine formula.
  ///
  /// @param lat1 The latitude of the first point.
  /// @param lon1 The longitude of the first point.
  /// @param lat2 The latitude of the second point.
  /// @param lon2 The longitude of the second point.
  /// @return The distance between the two points in kilometers.

  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    final a = pow(sin(dLat / 2), 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  /// Converts degrees to radians.
  ///
  /// @param deg The angle in degrees to be converted.
  /// @return The angle in radians.
  double _deg2rad(double deg) {
    return deg * (pi / 180.0);
  }
}
