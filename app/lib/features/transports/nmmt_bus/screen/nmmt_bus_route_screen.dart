import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:navixplore/core/utils/color_utils.dart';
import 'package:navixplore/features/transports/nmmt_bus/screen/nmmt_bus_no_schedules_screen.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';
import 'package:navixplore/features/widgets/bus_marker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Import
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_storage/get_storage.dart';
// Import DateFormat for robust time formatting (consider adding intl package dependency)
// import 'package:intl/intl.dart';

// Define constants for cache keys and report issue types
const String _polylineCacheKey = 'polyline_cache';
const String reportTypeMissingBusStop = 'Missing Bus Stop';
const String reportTypeWrongBusStopLocation = 'Wrong Bus Stop Location';
const String reportTypeOtherIssue = 'Other Issue';

class NMMT_BusRouteScreen extends StatefulWidget {
  final int routeid;
  final String busName;
  final String? busTripId;
  final String? busArrivalTime;
  final String? routeNo;

  const NMMT_BusRouteScreen({
    Key? key,
    required this.routeid,
    required this.busName,
    this.busTripId,
    this.busArrivalTime,
    this.routeNo,
  }) : super(key: key);

  @override
  State<NMMT_BusRouteScreen> createState() => _NMMT_BusRouteScreenState();
}

class _NMMT_BusRouteScreenState extends State<NMMT_BusRouteScreen> {
  bool isLoading = true;
  Timer? _timer;
  List<dynamic>? busStopDataList;
  List<dynamic>? busStopPositionDataList;
  List<dynamic>? busPositionDataList;
  late int routeid;
  List<Marker> markers = [];
  final MapController mapController = MapController();
  PanelController panelController = PanelController();
  List<LatLng> polylinePoints = [];
  final PolylinePoints polylinePointsHelper = PolylinePoints();
  final _storage = GetStorage();
  String? errorMessage; // For displaying error messages on screen

  // Report-related variables
  String? _selectedReportType;
  String? _selectedBusStop;
  final TextEditingController _missingBusStopController =
  TextEditingController();
  final TextEditingController _otherIssueController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    routeid = widget.routeid;
    _initStorage();
    initialize();
  }

  Future<void> _initStorage() async {
    await GetStorage.init();
  }

  void initialize() async {
    await _fetchAllBusStopData();
    if (busStopDataList != null && busStopDataList!.isNotEmpty) {
      await fetchInitialData();

      _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
        _fetchBusPositionData();
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading if busStopDataList is empty after fetching
      });
    }
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Clear any previous error message
    });
    try {
      await Future.wait([
        _fetchBusPositionData(),
        _fetchRoutePolyline(),
      ]);
    } catch (e) {
      print('Error during initial data fetch: $e');
      setState(() {
        errorMessage =
        'Failed to load route data. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _missingBusStopController.dispose();
    _otherIssueController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllBusStopData() async {
    try {
      final busStopQuery = await FirebaseFirestore.instance
          .collection('NMMT-Buses')
          .where('routeID', isEqualTo: widget.routeid)
          .get();

      if (busStopQuery.docs.isNotEmpty) {
        final busStopData =
        busStopQuery.docs.first.data() as Map<String, dynamic>;
        setState(() {
          busStopDataList = busStopData['stations'] as List<dynamic>?;
        });

        if (busStopDataList != null && busStopDataList!.isNotEmpty) {
          final firstStationID = busStopDataList![0]['stationid'];
          final lastStationID = busStopDataList!.last['stationid'];
          await _fetchBusStopPositionData(firstStationID, lastStationID);
        }
      } else {
        setState(() {
          busStopDataList = []; // Set to empty list if no data from Firestore
        });
      }
    } catch (e) {
      print('Error fetching bus stop data from Firestore: $e');
      setState(() {
        busStopDataList = null; // Set to null to indicate error
        errorMessage = 'Failed to load bus route information.';
      });
    }
  }

  Future<void> _fetchBusStopPositionData(
      int firstStationID, int lastStationID) async {
    try {
      String routeIDString = routeid.toString();
      String firstStationIDString = firstStationID.toString();
      String lastStationIDString = lastStationID.toString();

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusStopsBetweenSoureDestination}?RouteId=$routeIDString&FromStaionId=$firstStationIDString&ToStaionId=$lastStationIDString',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
            .innerText
            .trim()
            .toUpperCase() ==
            "NO DATA FOUND") {
          setState(() {
            busStopPositionDataList = [];
          });
        } else {
          final List<dynamic> busStopPosition =
          json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            busStopPositionDataList = busStopPosition;
          });
        }
      } else {
        print(
            'Failed to fetch bus stop positions. Status code: ${response.statusCode}');
        _showErrorSnackBar('Failed to load bus stop positions.');
      }
    } catch (error) {
      print('Error fetching bus stop positions: $error');
      _showErrorSnackBar(
          'Error loading bus stop positions. Please check your connection.');
    }
  }

  Future<void> _fetchBusPositionData() async {
    if (widget.busTripId == null || widget.busArrivalTime == null) {
      print(
          'Warning: busTripId or busArrivalTime is null, skipping bus position fetch.');
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusTrackerDetails}?TripId=${widget.busTripId}&TripStatus=1&TripStartTime=${widget.busArrivalTime}',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
            .innerText
            .trim()
            .toUpperCase() ==
            "NO DATA FOUND") {
          setState(() {
            busPositionDataList = [];
          });
        } else {
          final List<dynamic> busPosition =
          json.decode(xml.XmlDocument.parse(response.data).innerText);

          setState(() {
            busPositionDataList = busPosition;
          });

          if (busPositionDataList != null && busPositionDataList!.isNotEmpty) {
            final busLatitude =
                double.tryParse(busPositionDataList![0]["CurrentLat"] ?? '') ??
                    0.0;
            final busLongitude = double.tryParse(
                busPositionDataList![0]["CurrentLong"] ?? '') ??
                0.0;
            if (mounted) {
              // Check if widget is still mounted before using mapController
              mapController.move(
                  LatLng(busLatitude, busLongitude), mapController.camera.zoom);
            }
          }
        }
      } else {
        print(
            'Failed to fetch bus positions. Status code: ${response.statusCode}');
        _showErrorSnackBar('Failed to update bus location.');
      }
    } catch (error) {
      print('Error fetching bus positions: $error');
      _showErrorSnackBar(
          'Error updating bus location. Please check your connection.');
    }
  }

  Future<void> _fetchRoutePolyline() async {
    if (busStopPositionDataList == null || busStopPositionDataList!.isEmpty) {
      return;
    }

    final cachedPolyline = await _getCachedPolyline();
    if (cachedPolyline != null) {
      setState(() {
        polylinePoints = cachedPolyline;
      });
      return;
    }

    final dio = Dio();
    List<LatLng> allPoints = [];

    String waypoints = '';
    for (final stop in busStopPositionDataList!) {
      final lat = double.tryParse(stop['STATIONLAT'] ?? '') ?? 0.0;
      final lng = double.tryParse(stop['STATIONLONG'] ?? '') ?? 0.0;
      waypoints += '$lng,$lat;';
    }
    waypoints = waypoints.substring(0, waypoints.length - 1);

    final url =
        'http://router.project-osrm.org/route/v1/driving/$waypoints?steps=true';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            data['routes'] != null &&
            data['routes'] is List &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          if (route['geometry'] != null) {
            String encodedPolyline = route['geometry'];
            final points = polylinePointsHelper.decodePolyline(encodedPolyline);
            if (points.isNotEmpty) {
              List<LatLng> segmentPoints = points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList();
              allPoints.addAll(segmentPoints);
            } else {
              print('OSRM decoded polyline is empty');
            }
          } else {
            print('Geometry is null in OSRM response');
          }
        } else {
          print('No routes array found or is empty in OSRM response');
        }
      } else {
        print(
            'Failed to fetch route polyline from OSRM. Status code: ${response.statusCode}');
        _showErrorSnackBar('Failed to load route path.');
      }
    } catch (e) {
      print('Error fetching route polyline: $e');
      _showErrorSnackBar(
          'Error loading route path. Please check your connection.');
    } finally {
      setState(() {
        polylinePoints = allPoints;
      });
      _cachePolyline(allPoints);
    }
  }

  Future<void> _cachePolyline(List<LatLng> polyline) async {
    final encodedPolyline = jsonEncode(
        polyline.map((latLng) => [latLng.latitude, latLng.longitude]).toList());
    await _storage.write(
        '$_polylineCacheKey${widget.routeid}', encodedPolyline);
  }

  Future<List<LatLng>?> _getCachedPolyline() async {
    final cachedPolylineString =
    await _storage.read('$_polylineCacheKey${widget.routeid}');
    if (cachedPolylineString != null) {
      try {
        final decodedList = jsonDecode(cachedPolylineString) as List;
        return decodedList.map((coord) => LatLng(coord[0], coord[1])).toList();
      } catch (e) {
        print('Error decoding cached polyline: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      Map<String, dynamic> reportData = {
        'reportType': _selectedReportType,
        'routeId': widget.routeid,
        'busName': widget.busName,
        'timestamp': DateTime.now().toIso8601String(),
        'device': await getDeviceDetails(),
      };

      if (_selectedReportType == reportTypeMissingBusStop) {
        reportData['missingBusStopName'] = _missingBusStopController.text;
      } else if (_selectedReportType == reportTypeWrongBusStopLocation) {
        reportData['wrongBusStop'] = _selectedBusStop;
      } else if (_selectedReportType == reportTypeOtherIssue) {
        reportData['otherIssueDescription'] = _otherIssueController.text;
      }

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      _clearReportForm();
    } catch (e) {
      print('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearReportForm() {
    setState(() {
      _selectedReportType = null;
      _selectedBusStop = null;
    });
    _missingBusStopController.clear();
    _otherIssueController.clear();
  }

  Future<Map<String, String>> getDeviceDetails() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      return {
        'os': deviceInfo.data['os']?.toString() ?? 'Unknown',
        'device_name': deviceInfo.data['name']?.toString() ?? 'Unknown',
        'id': deviceInfo.data['id']?.toString() ?? 'Unknown',
      };
    } catch (e) {
      print('Error getting device details: $e');
      return {
        'os': 'Unknown',
        'device_name': 'Unknown',
        'id': 'Unknown',
      };
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          if (isLoading)
            _buildLoadingScreen()
          else if (errorMessage != null)
            _buildErrorScreen()
          else if (busStopDataList == null || busStopDataList!.isEmpty)
              _buildNoDataScreen()
            else
              _buildBusRouteScreen(),
          Positioned(
            top: 20,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                  child: BackButton(
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ),
          if (!isLoading && errorMessage == null && busStopDataList != null && busStopDataList!.isNotEmpty)
            Positioned(
              top: 20,
              right: 10,
              child: GestureDetector(
                  onTap: () {
                    fetchInitialData(); // Refresh all data on map refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        content: const Text(
                          'Refreshing Map...',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.refresh,
                          color: Theme.of(context).primaryColor))),
            ),
          if (!isLoading && errorMessage == null && busStopDataList != null && busStopDataList!.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _showReportDialog();
                },
                child: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                  child:
                  Icon(Icons.report, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  String _formatTime(String time) {
    // Consider using DateFormat from intl package for more robust parsing and formatting
    // Example using intl (add dependency: intl: ^0.18.0 to pubspec.yaml):
    // final parsedTime = DateFormat('h:mm a').parse(time);
    // return DateFormat('hh:mm a').format(parsedTime); // Or any desired format

    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return '${hour}:${minute.toString().padLeft(2, '0')} ${parts[1]}';
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/animations/bus_loading.gif',
            ),
            const SizedBox(height: 24),
            Text(
              'Tracking Your Bus Route',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Fetching real-time bus location, route details, and stop information...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 5,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connecting to NMMT Services',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'An error occurred while loading data.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Oops! No Data Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This route might be temporarily or permanently closed. 😞',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: initialize, // Retry initialize to refetch bus stop data
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBusRouteScreen() {
    markers.clear();
    if (busStopPositionDataList != null) {
      for (final busStopPosition in busStopPositionDataList!) {
        final busLatitude =
            double.tryParse(busStopPosition['STATIONLAT'] as String? ?? '') ??
                0.0;
        final busLongitude =
            double.tryParse(busStopPosition['STATIONLONG'] as String? ?? '') ??
                0.0;
        markers.add(
          Marker(
            point: LatLng(busLatitude, busLongitude),
            width: 30,
            height: 30,
            child: busStopMarkerWidget(context),
          ),
        );
      }
    }
    final busMarker = BusMarker(routeNo: widget.routeNo ?? '');

    if (busPositionDataList != null && busPositionDataList!.isNotEmpty) {
      markers.add(
        Marker(
          point: LatLng(
            double.tryParse(busPositionDataList![0]["CurrentLat"] ?? '') ?? 0.0,
            double.tryParse(busPositionDataList![0]["CurrentLong"] ?? '') ?? 0.0,
          ),
          width: 75,
          child: busMarker,
        ),
      );
    }
    double panelMaxHeight = MediaQuery.of(context).size.height * 0.6;
    double panelClosedHeight = 100;

    return SlidingUpPanel(
      defaultPanelState: PanelState.OPEN,
      maxHeight: panelMaxHeight,
      minHeight: panelClosedHeight,
      parallaxEnabled: true,
      parallaxOffset: 0.5,
      panelSnapping: false,
      controller: panelController,
      color: ColorUtils.hexToColor('#F5F5F5'),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      body: _buildMap(),
      panel: _buildPanel(),
    );
  }

  Widget _buildMap() {
    LatLng initialCenter = LatLng(0, 0); // Default center
    double initialZoom = 15;

    if (busPositionDataList != null && busPositionDataList!.isNotEmpty) {
      initialCenter = LatLng(
        double.tryParse(busPositionDataList![0]["CurrentLat"] ?? '') ??
            (busStopPositionDataList != null && busStopPositionDataList!.isNotEmpty ? double.tryParse(busStopPositionDataList![0]['STATIONLAT'] ?? '') ?? 0.0 : 0.0),
        double.tryParse(busPositionDataList![0]["CurrentLong"] ?? '') ??
            (busStopPositionDataList != null && busStopPositionDataList!.isNotEmpty ? double.tryParse(busStopPositionDataList![0]['STATIONLONG'] ?? '') ?? 0.0 : 0.0),
      );
    } else if (busStopPositionDataList != null && busStopPositionDataList!.isNotEmpty) {
      initialCenter = LatLng(
        double.tryParse(busStopPositionDataList![0]['STATIONLAT'] ?? '') ?? 0.0,
        double.tryParse(busStopPositionDataList![0]['STATIONLONG'] ?? '') ?? 0.0,
      );
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.navixplore.navixplore',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: polylinePoints,
              color: Colors.blue,
              strokeWidth: 4.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            panelController.isPanelOpen
                ? panelController.close()
                : panelController.open();
          },
          child: Center(
            child: Container(
              width: 30,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.busName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _buildBusStopTimeline(),
        ),
      ],
    );
  }

  Widget _buildBusStopTimeline() {
    return ListView.builder(
      itemCount: busStopDataList?.length ?? 0,
      itemBuilder: (context, index) {
        final busStopData = busStopDataList![index];
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.075,
          isFirst: index == 0,
          isLast: index == busStopDataList!.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            iconStyle: IconStyle(
              iconData: Icons.check,
              color: Colors.white,
              fontSize: 14,
            ),
            indicator: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: busPositionDataList != null &&
                    busPositionDataList!.isNotEmpty &&
                    busStopDataList![index]['StationId'] ==
                        busPositionDataList![index]['STATIONID']
                    ? busPositionDataList![index]["CoveredStatus"] == "covered"
                    ? Theme.of(context).primaryColor
                    : busPositionDataList![index]["CoveredStatus"] ==
                    "notcovered"
                    ? Colors.white
                    : Colors.red
                    : Colors.white,
              ),
            ),
          ),
          beforeLineStyle: LineStyle(
            thickness: 20,
            color: Colors.grey.shade300,
          ),
          afterLineStyle: LineStyle(
            thickness: 20,
            color: Colors.grey.shade300,
          ),
          endChild: _buildTimelineListTile(busStopData, index),
        );
      },
    );
  }

  Widget _buildTimelineListTile(dynamic busStopData, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NMMT_BusNumberSchedulesScreen(
              routeid: routeid,
              busName: widget.busName,
              busStopName: busStopData["stationname"],
              stationid: busStopData["stationid"],
            ),
          ),
        );
      },
      title: Text(busStopData['stationname'] ?? 'N/A'),
      subtitle: Text(busStopData['stationname_m'] ?? 'N/A'),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            busPositionDataList != null &&
                busPositionDataList!.length > index // Check index bounds
                ? _formatTime(busPositionDataList![index]["ETA"] ?? "")
                : "",
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            busPositionDataList != null &&
                busPositionDataList!.length > index // Check index bounds
                ? "Distance: ${busPositionDataList![index]["Distance"] ?? ""} km"
                : "",
          ),
        ],
      ),
    );
  }


  // Report dialog code (same as before, no major changes needed here)
  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 20),
          child: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.report,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Report Issue',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Issue Type',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedReportType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedReportType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an issue type';
                          }
                          return null;
                        },
                        items: const [
                          reportTypeMissingBusStop,
                          reportTypeWrongBusStopLocation,
                          reportTypeOtherIssue,
                        ].map((issue) {
                          return DropdownMenuItem<String>(
                            value: issue,
                            child: Text(issue),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedReportType == reportTypeMissingBusStop)
                        TextFormField(
                          controller: _missingBusStopController,
                          decoration: const InputDecoration(
                            labelText: 'Missing Bus Stop Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the name of the missing bus stop';
                            }
                            return null;
                          },
                        ),
                      if (_selectedReportType == reportTypeWrongBusStopLocation)
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Bus Stop',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedBusStop,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedBusStop = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the wrong placed bus stop';
                            }
                            return null;
                          },
                          items: busStopDataList?.map((busStop) {
                            return DropdownMenuItem<String>(
                              value: busStop['stationname'],
                              child: Text(busStop['stationname'] ?? 'N/A'),
                            );
                          }).toList() ??
                              [],
                        ),
                      if (_selectedReportType == reportTypeOtherIssue)
                        TextFormField(
                          controller: _otherIssueController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Issue Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please provide issue description';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _submitReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit Report'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
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

  Widget busStopSkeleton() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              const SizedBox(height: 5),
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
          const SizedBox(width: 10),
          Skeleton(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
    );
  }

  Widget busStopMarkerWidget(BuildContext context) {
    return CircleAvatar(
      radius: 15.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: CircleAvatar(
        radius: 10.0,
        backgroundColor: Colors.white,
        child: Icon(Icons.directions_bus,
            color: Theme.of(context).primaryColor, size: 15),
      ),
    );
  }
}