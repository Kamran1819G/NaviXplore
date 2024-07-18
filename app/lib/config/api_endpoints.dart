class NMMTApiEndpoints{
  static String GetNearByBusStops(double latitude, double longitude){
    return "https://nmmtservice.infinium.management/TransistService.asmx/GetNearByDepotList?Lattitude=$latitude&Longitude=$longitude";
  }
  static const String GetRouteList = "https://nmmtservice.infinium.management/TransistService.asmx/GetRouteList";
  static const String GetDepotBusesList ="https://nmmtservice.infinium.management/TransistService.asmx/GetDepotWiseBusList_test2";
  static const String GetBusStop = "https://nmmtservice.infinium.management/TransistService.asmx/GetStationList";
  static const String GetBusList ="https://nmmtservice.infinium.management/TransistService.asmx/GetRouteList";
  static const String GetBusTrackerDetails = "https://nmmtservice.infinium.management/TransistService.asmx/GetBusTrackerDetails";
  static const String GetBusScheduleForRoute = "https://nmmtservice.infinium.management/TransistService.asmx/GetBusScheduleForRoute";
  static const String GetBusStopsFromRoute = "https://nmmtservice.infinium.management/TransistService.asmx/GetStationsFromRoute";
  static const String GetBusStopsBetweenSoureDestination = "https://nmmtservice.infinium.management/TransistService.asmx/GetStationBetweenSoureDestination";
  static const String GetBusFromSourceToDestination = "https://nmmtservice.infinium.management/TransistService.asmx/GetBusFromSourceToDestination";
}
