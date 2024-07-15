import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:navixplore/components/home_tabs/nmmt_bus/nmmt_all_nearest_bus_stop.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:navixplore/pages/announcement_detail_page.dart';
import 'package:navixplore/services/NMMT_Service.dart';
import 'package:navixplore/services/permission_handler_service.dart';
import 'package:navixplore/widgets/Skeleton.dart';
import 'package:navixplore/widgets/announcement_card.dart';
import 'package:navixplore/widgets/webview_screen.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:xml/xml.dart' as xml;

import 'nmmt_bus_search_page.dart';
import 'nmmt_depot_buses.dart';

class NMMTBusTab extends StatefulWidget {
  const NMMTBusTab({Key? key}) : super(key: key);

  @override
  State<NMMTBusTab> createState() => _NMMTBusTabState();
}

class _NMMTBusTabState extends State<NMMTBusTab> {
  List<dynamic>? nearbyBusStop;
  Set<Marker> markers = Set();
  bool isLoading = true;
  bool isAnnouncementLoading = true;
  double? _latitude;
  double? _longitude;
  BitmapDescriptor? busStopMarker;
  Timer? _timer;

  final NMMTService _nmmtService = NMMTService();
  final PermissionHandlerService _permissionHandlerService = PermissionHandlerService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initialize() async {
    _getNearbyBusStops();
    try {
      await _nmmtService.fetchAnnouncements();
      setState(() {
        isAnnouncementLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isAnnouncementLoading = false;
      });
    }
    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      _getNearbyBusStops();
    });
    setCustomMarker();
  }

  Future<void> setCustomMarker() async {
    final busStopMarker = await busStopMarkerWidget().toBitmapDescriptor(
      logicalSize: const Size(150, 150),
      imageSize: const Size(200, 200),
    );
    setState(() {
      this.busStopMarker = busStopMarker;
    });
  }

  Future<void> _getNearbyBusStops() async {
    try {
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      } else {
        await _permissionHandlerService.requestLocationPermission();
        await _getNearbyBusStops();
        return;
      }

      setState(() {
        isLoading = true;
      });

      final dio = Dio();
      final response = await dio.get(
        NMMTApiEndpoints.GetNearByBusStops(_latitude!, _longitude!),
      );

      if (response.statusCode == 200) {
        final List<dynamic> busStop = json.decode(xml.XmlDocument.parse(response.data).innerText);
        setState(() {
          nearbyBusStop = busStop;
          isLoading = false;
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDistance(String distanceInKm) {
    double distance = double.parse(distanceInKm);

    if (distance >= 1) {
      return '${distance.toStringAsFixed(2)} km';
    } else {
      int meters = (distance * 1000).round();
      return '$meters m';
    }
  }

  String calculateTime(String distanceInKm) {
    double distance = double.parse(distanceInKm);
    double time = distance / 0.08;
    if (time < 1) {
      return '1 min';
    }
    return '${time.toStringAsFixed(0)} min';
  }

  @override
  Widget build(BuildContext context) {
    markers.clear();
    for (int i = 0; i < (nearbyBusStop?.length ?? 0); i++) {
      final busStopData = nearbyBusStop![i];
      if (busStopData != null) {
        markers.add(
          Marker(
            markerId: MarkerId(busStopData["StationName"] ?? ""),
            position: LatLng(
              double.parse(busStopData["Center_Lat"] ?? "0.0"),
              double.parse(busStopData["Center_Lon"] ?? "0.0"),
            ),
            icon: busStopMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: busStopData["StationName"] ?? "",
            ),
            zIndex: 1,
          ),
        );
        if (i == 9) {
          break;
        }
      }
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NMMTBusSearchPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(width: 1, color: Colors.orange.shade900),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/icons/NMMT.png",
                        height: 25,
                      )),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter destination or Bus number",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.orange.shade800,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Nearest Bus Stop",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllNearestBusStop(
                        nearbyBusStop: nearbyBusStop,
                      ),
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemExtent: 70,
                  itemBuilder: (context, index) => busStopSkeleton(),
                )
              : nearbyBusStop == null || nearbyBusStop!.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "😢 Oops! Something went wrong.",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'We couldn\'t retrieve nearby bus stops at the moment.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        final busStopData = nearbyBusStop![index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NMMTDepotBuses(
                                  busStopName: busStopData["StationName"],
                                  stationid:
                                      int.parse(busStopData["StationId"]),
                                  stationLocation: {
                                    '_latitude':
                                        double.parse(busStopData['Center_Lat']),
                                    '_longitude':
                                        double.parse(busStopData['Center_Lon']),
                                  },
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.orange,
                            child: CircleAvatar(
                              radius: 15.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.directions_bus,
                                  color: Colors.orange, size: 20),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                busStopData["StationName"],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                busStopData["StationName_M"],
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "${busStopData["RouteNo"]}",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                calculateTime(busStopData["Distance"]),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "~ ${formatDistance(busStopData["Distance"])}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "News & Updates",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 400,
            child: isAnnouncementLoading
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) => announcementSkeleton(),
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _nmmtService.announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = _nmmtService.announcements[index];
                      return GestureDetector(
                        onTap: () {
                          if (announcement['link'] != null) {
                            WebView_Screen(
                                url: announcement['link'],
                                title: announcement['title']);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnnouncementDetailPage(
                                  announcement: announcement,
                                ),
                              ),
                            );
                          }
                        },
                        child: AnnouncementCard(
                          imageUrl: announcement["imageUrl"],
                          title: announcement["title"],
                          description: announcement["description"],
                          releaseAt: announcement["releaseAt"],
                          source: announcement["source"],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                  ),
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Bus Stops Around You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isLoading
                ? mapSkeleton(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                  )
                : GoogleMap(
                    mapType: MapType.terrain,
                    myLocationEnabled: true,
                    fortyFiveDegreeImageryEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_latitude ?? 0, _longitude ?? 0),
                      zoom: 16,
                    ),
                    markers: markers,
                    onTap: (latLng) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllNearestBusStop(),
                        ),
                      );
                    }),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Make your everyday travel easy with NMMT and NaviXplore",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/icons/NMMT.png",
                    height: 50,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget busStopSkeleton() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Skeleton(
            height: 40,
            width: 40,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 5),
              Skeleton(
                height: 15,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ],
          ),
          Skeleton(
            height: 30,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
    );
  }

  Widget mapSkeleton({required double height, required double width}) {
    return Center(
      child: Skeleton(
        height: height,
        width: width,
      ),
    );
  }

  Widget busStopMarkerWidget() {
    return CircleAvatar(
      radius: 30.0,
      backgroundColor: Colors.orange,
      child: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.white,
        child: Icon(Icons.directions_bus, color: Colors.orange, size: 30),
      ),
    );
  }

  Widget announcementSkeleton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            child: Skeleton(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Skeleton(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Skeleton(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
