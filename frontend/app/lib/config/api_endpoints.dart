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

class NM_MetroApiEndpoints{
  static const String GetStations = "https://navixplore.onrender.com/api/nm-metro/stations";
  static String GetNearestStation (double latitude, double longitude) {
    return "https://navixplore.onrender.com/api/nm-metro/stations/nearest?latitude=$latitude&longitude=$longitude";
  }
  static String SearchStation (String query) {
    return "https://navixplore.onrender.com/api/nm-metro/stations/search?query=$query";
  }
  static String GetUpcomingTrains (String lineID, String direction, String stationID){
    return "https://navixplore.onrender.com/api/nm-metro/trains/upcoming?lineID=$lineID&direction=$direction&stationID=$stationID";
  }
  static String GetMetroSchedule (String lineID, String direction, int trainNo) {
    return "https://navixplore.onrender.com/api/nm-metro/trains/schedule?lineID=$lineID&direction=$direction&trainNo=$trainNo";
  }
  static String GetlineData (String lineID) {
    return "https://navixplore.onrender.com/api/nm-metro/lines?lineID=$lineID";
  }
}

class PlacesApiEndpoints{
  static const String FamousPlaces = 'https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/FamousPlaces.json';
  static const String TouristDestinations = 'https://raw.githubusercontent.com/Kamran1819G/NaviXplore-Website-NextJS/master/src/json/TouristDestinations.json';
}