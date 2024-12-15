class NMMTApiEndpoints {
  static const String _baseUrl = "https://nmmtservice.infinium.management/TransistService.asmx";

  static String GetNearByBusStops(double latitude, double longitude) {
    return Uri.https(
      "nmmtservice.infinium.management",
      "/TransistService.asmx/GetNearByDepotList",
      {
        "Lattitude": latitude.toString(),
        "Longitude": longitude.toString(),
      },
    )
        .toString();
  }

  static const String GetRouteList = "$_baseUrl/GetRouteList";
  static const String GetDepotBusesList = "$_baseUrl/GetDepotWiseBusList_test2";
  static const String GetBusStop = "$_baseUrl/GetStationList";
  static const String GetBusList = "$_baseUrl/GetRouteList";
  static const String GetBusTrackerDetails = "$_baseUrl/GetBusTrackerDetails";
  static const String GetBusScheduleForRoute = "$_baseUrl/GetBusScheduleForRoute";
  static const String GetBusStopsFromRoute = "$_baseUrl/GetStationsFromRoute";
  static const String GetBusStopsBetweenSoureDestination =
      "$_baseUrl/GetStationBetweenSoureDestination";
  static const String GetBusFromSourceToDestination =
      "$_baseUrl/GetBusFromSourceToDestination";
}