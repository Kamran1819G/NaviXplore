class NearbyBusStopModel {
  final String stationName;
  final String stationNameMarathi;
  final String stationId;
  final double centerLat;
  final double centerLon;
  final double distance;
  final String buses;

  NearbyBusStopModel({
    required this.stationName,
    required this.stationNameMarathi,
    required this.stationId,
    required this.centerLat,
    required this.centerLon,
    required this.distance,
    required this.buses,
  });

  factory NearbyBusStopModel.fromJson(Map<String, dynamic> json) {
    return NearbyBusStopModel(
      stationName: json['StationName']?.toString() ?? '',
      stationNameMarathi: json['StationName_M']?.toString() ?? '',
      stationId: json['StationId']?.toString() ?? '',
      centerLat: double.tryParse(json['Center_Lat']?.toString() ?? '0.0') ?? 0.0, // Safe parsing
      centerLon: double.tryParse(json['Center_Lon']?.toString() ?? '0.0') ?? 0.0, // Safe parsing
      distance: double.tryParse(json['Distance']?.toString() ?? '0.0') ?? 0.0,   // Safe parsing
      buses: json['Buses']?.toString() ?? '',
    );
  }
}