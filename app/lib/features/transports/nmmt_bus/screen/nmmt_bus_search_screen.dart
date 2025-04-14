import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:navixplore/features/transports/nmmt_bus/controller/nmmt_controller.dart';
import 'package:navixplore/features/widgets/Skeleton.dart';
import 'package:quickalert/quickalert.dart';
import 'package:xml/xml.dart' as xml;

import 'nmmt_bus_no_search_screen.dart';
import 'nmmt_bus_route_screen.dart';
import 'nmmt_bus_stop_search_screen.dart';

class NMMT_BusSearchScreen extends StatefulWidget {
  const NMMT_BusSearchScreen({Key? key}) : super(key: key);

  @override
  State<NMMT_BusSearchScreen> createState() => _NMMT_BusSearchScreenState();
}

class _NMMT_BusSearchScreenState extends State<NMMT_BusSearchScreen> {
  List<dynamic>? busDataList;
  bool isLoading = true;
  Timer? _timer;
  final String busServiceTypeId = "0";
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  int? sourceLocationId;
  int? destinationLocationId;
  List<dynamic> _filteredSourceSuggestions = [];
  List<dynamic> _filteredDestinationSuggestions = [];
  bool _showSourceSuggestions = false;
  bool _showDestinationSuggestions = false;
  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  final NMMTController controller = Get.find<NMMTController>();
  List<Map<String, dynamic>> _savedRoutes = [];
  List<Map<String, dynamic>> _recentSearches = [];
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    initialize();
    _loadSavedRoutes();
    _loadRecentSearches();
    _sourceFocusNode.addListener(_onSourceFocusChange);
    _destinationFocusNode.addListener(_onDestinationFocusChange);
  }

  void _onSourceFocusChange() {
    setState(() {
      _showSourceSuggestions = _sourceFocusNode.hasFocus;
    });
  }

  void _onDestinationFocusChange() {
    setState(() {
      _showDestinationSuggestions = _destinationFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sourceFocusNode.removeListener(_onSourceFocusChange);
    _destinationFocusNode.removeListener(_onDestinationFocusChange);
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void initialize() async {
    await controller.fetchAllStations();
    _timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      _fetchRunningBusData(sourceLocationId, destinationLocationId);
    });
  }

  void _interchangeLocations() {
    setState(() {
      String tempLocation = sourceLocationController.text;
      sourceLocationController.text = destinationLocationController.text;
      destinationLocationController.text = tempLocation;

      int? tempLocationId = sourceLocationId;
      sourceLocationId = destinationLocationId;
      destinationLocationId = tempLocationId;

      _fetchRunningBusData(sourceLocationId, destinationLocationId);
    });
  }

  Future<void> _fetchRunningBusData(
      int? sourceLocationId, int? destinationLocationId) async {
    try {
      setState(() {
        isLoading = true;
      });

      String? sourceLocation = sourceLocationId?.toString();
      String? destinationLocation = destinationLocationId?.toString();

      DateTime now = DateTime.now();
      String scheduleDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      String currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusFromSourceToDestination}?FromLocId=$sourceLocation&ToLocId=$destinationLocation&BusServiceTypeId=$busServiceTypeId&ScheduleDate=$scheduleDate&JourneyTime=$currentTime',
      );

      if (response.statusCode == 200) {
        final xmlData =
            xml.XmlDocument.parse(response.data).innerText.trim().toUpperCase();
        if (xmlData == "NO BUS AVAILABLE") {
          setState(() {
            busDataList = [];
          });
        } else {
          final List<dynamic> buses = json.decode(xmlData);
          setState(() {
            busDataList = buses;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterSourceSuggestions(String query) {
    if (query.length >= 3) {
      setState(() {
        _filteredSourceSuggestions = controller.allBusStops
                .where((stop) =>
                    stop['stationName']['English']
                        ?.toLowerCase()
                        ?.contains(query.toLowerCase()) ??
                    false ||
                        stop['stationName']['Marathi']
                            ?.toLowerCase()
                            ?.contains(query.toLowerCase()) ??
                    false)
                .toList() ??
            [];
        _showSourceSuggestions = true;
      });
    } else {
      setState(() {
        _filteredSourceSuggestions = [];
        _showSourceSuggestions = false;
      });
    }
  }

  void _filterDestinationSuggestions(String query) {
    if (query.length >= 3) {
      setState(() {
        _filteredDestinationSuggestions = controller.allBusStops
                .where((stop) =>
                    stop['stationName']['English']
                        ?.toLowerCase()
                        ?.contains(query.toLowerCase()) ??
                    false ||
                        stop['stationName']['Marathi']
                            ?.toLowerCase()
                            ?.contains(query.toLowerCase()) ??
                    false)
                .toList() ??
            [];
        _showDestinationSuggestions = true;
      });
    } else {
      setState(() {
        _filteredDestinationSuggestions = [];
        _showDestinationSuggestions = false;
      });
    }
  }

  Future<void> _loadSavedRoutes() async {
    final savedRoutesJson = _storage.read('savedRoutes');
    if (savedRoutesJson != null) {
      setState(() {
        _savedRoutes = (json.decode(savedRoutesJson) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    final recentSearchesJson = _storage.read('recentSearches');
    if (recentSearchesJson != null) {
      setState(() {
        _recentSearches = (json.decode(recentSearchesJson) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _saveSearch(String source, String destination, int sourceId,
      int destinationId) async {
    final newSearch = {
      'source': source,
      'destination': destination,
      'sourceId': sourceId,
      'destinationId': destinationId
    };

    setState(() {
      _recentSearches.removeWhere((search) =>
          search['sourceId'] == sourceId &&
          search['destinationId'] == destinationId);

      _recentSearches.insert(0, newSearch);

      if (_recentSearches.length > 2) {
        _recentSearches.removeLast();
      }
    });
    final recentSearchesJson = json.encode(_recentSearches);
    await _storage.write('recentSearches', recentSearchesJson);
  }

  Future<void> _saveRoute(String source, String destination, int sourceId,
      int destinationId) async {
    final newRoute = {
      'source': source,
      'destination': destination,
      'sourceId': sourceId,
      'destinationId': destinationId
    };

    final routeExists = _savedRoutes.any((route) =>
        route['sourceId'] == sourceId &&
        route['destinationId'] == destinationId);

    if (!routeExists) {
      setState(() {
        _savedRoutes.add(newRoute);
      });
      final savedRoutesJson = json.encode(_savedRoutes);
      await _storage.write('savedRoutes', savedRoutesJson);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Route Saved',
        text: 'The route has been successfully added to your saved routes.',
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Duplicate Route',
        text: 'This route is already in your saved routes.',
      );
    }
  }

  Future<void> _clearAllRecentSearches(VoidCallback refreshCallback) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'Are you sure you want to delete all recent searches?',
      confirmBtnText: 'Delete All',
      confirmBtnColor: Colors.red,
      showCancelBtn: true,
      onConfirmBtnTap: () async {
        setState(() {
          _recentSearches.clear();
        });
        final recentSearchesJson = json.encode(_recentSearches);
        await _storage.write('recentSearches', recentSearchesJson);
        Navigator.pop(context);
        refreshCallback();
      },
    );
  }

  Future<void> _deleteRoute(int index, VoidCallback refreshCallback) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'Are you sure you want to delete this route?',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      showCancelBtn: true,
      onConfirmBtnTap: () async {
        setState(() {
          _savedRoutes.removeAt(index);
        });
        final savedRoutesJson = json.encode(_savedRoutes);
        await _storage.write('savedRoutes', savedRoutesJson);
        Navigator.pop(context);
        refreshCallback();
      },
    );
  }

  void _loadSearch(Map<String, dynamic> search) {
    setState(() {
      sourceLocationController.text = search['source'];
      destinationLocationController.text = search['destination'];
      sourceLocationId = search['sourceId'];
      destinationLocationId = search['destinationId'];
    });
    _fetchRunningBusData(sourceLocationId, destinationLocationId);
  }

  void _loadRoute(Map<String, dynamic> route) {
    setState(() {
      sourceLocationController.text = route['source'];
      destinationLocationController.text = route['destination'];
      sourceLocationId = route['sourceId'];
      destinationLocationId = route['destinationId'];
    });
    _fetchRunningBusData(sourceLocationId, destinationLocationId);
  }

  void _showSavedRoutesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext bc) {
        return _SavedRoutesBottomSheetContent(
          savedRoutes: _savedRoutes,
          onRouteSelected: _loadRoute,
          onRouteDeleted: (index, refreshCallback) {
            _deleteRoute(index, refreshCallback);
          },
          onClearAllRoutes: (refreshCallback) {
            _clearAllRoutes(refreshCallback);
          },
        );
      },
    );
  }

  void _showRecentSearchesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext bc) {
        return _RecentSearchesBottomSheetContent(
          recentSearches: _recentSearches,
          onSearchSelected: _loadSearch,
          onClearAllSearches: (refreshCallback) {
            _clearAllRecentSearches(refreshCallback);
          },
        );
      },
    );
  }

  void _clearAllRoutes(VoidCallback refreshCallback) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'Are you sure you want to delete all saved routes?',
      confirmBtnText: 'Delete All',
      confirmBtnColor: Colors.red,
      showCancelBtn: true,
      onConfirmBtnTap: () async {
        setState(() {
          _savedRoutes.clear();
          _storage.write('savedRoutes', json.encode([]));
        });
        Navigator.pop(context);
        refreshCallback();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _sourceFocusNode.unfocus();
        _destinationFocusNode.unfocus();
        setState(() {
          _showSourceSuggestions = false;
          _showDestinationSuggestions = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: const Text(
            "Search NMMT Bus",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _showSavedRoutesBottomSheet(context);
                },
                icon: const Icon(Icons.bookmark_border))
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Discover NMMT Bus services! Plan your journey and track real-time bus status!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: sourceLocationController,
                          focusNode: _sourceFocusNode,
                          onChanged: _filterSourceSuggestions,
                          onTap: () {
                            if (_recentSearches.isNotEmpty) {
                              _showRecentSearchesBottomSheet(context);
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                            suffixIcon: sourceLocationController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        sourceLocationController.clear();
                                        sourceLocationId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                  )
                                : null,
                            hintText: "Source Bus Station",
                            border: InputBorder.none,
                          ),
                        ),
                        if (_showSourceSuggestions &&
                            _filteredSourceSuggestions.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredSourceSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion =
                                    _filteredSourceSuggestions[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.directions_bus,
                                          color: Theme.of(context).primaryColor,
                                          size: 20),
                                    ),
                                  ),
                                  title: Text(
                                      suggestion['stationName']['English']),
                                  onTap: () {
                                    setState(() {
                                      sourceLocationController.text =
                                          suggestion['stationName']['English'];
                                      sourceLocationId =
                                          suggestion['stationID'];
                                      _showSourceSuggestions = false;
                                      _sourceFocusNode.unfocus();
                                      _filteredSourceSuggestions = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: destinationLocationController,
                          focusNode: _destinationFocusNode,
                          onChanged: _filterDestinationSuggestions,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                            suffixIcon: destinationLocationController
                                    .text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        destinationLocationController.clear();
                                        destinationLocationId = null;
                                        _fetchRunningBusData(sourceLocationId,
                                            destinationLocationId);
                                      });
                                    },
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                  )
                                : null,
                            hintText: "Destination Bus Station",
                            border: InputBorder.none,
                          ),
                        ),
                        if (_showDestinationSuggestions &&
                            _filteredDestinationSuggestions.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredDestinationSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion =
                                    _filteredDestinationSuggestions[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.directions_bus,
                                          color: Theme.of(context).primaryColor,
                                          size: 20),
                                    ),
                                  ),
                                  title: Text(
                                      suggestion['stationName']['English']),
                                  onTap: () {
                                    setState(() {
                                      destinationLocationController.text =
                                          suggestion['stationName']['English'];
                                      destinationLocationId =
                                          suggestion['stationID'];
                                      _showDestinationSuggestions = false;
                                      _destinationFocusNode.unfocus();
                                      _filteredDestinationSuggestions = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Tooltip(
                          message: 'Swap Source and Destination',
                          child: ElevatedButton(
                            onPressed: _interchangeLocations,
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            child: const Icon(Icons.swap_vert,
                                color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (sourceLocationController.text.isNotEmpty &&
                                destinationLocationController.text.isNotEmpty) {
                              _saveRoute(
                                  sourceLocationController.text,
                                  destinationLocationController.text,
                                  sourceLocationId ?? -1,
                                  destinationLocationId ?? -1);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    "Please fill in Source and Destination to Save"),
                              ));
                            }
                            _sourceFocusNode.unfocus();
                            _destinationFocusNode.unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _fetchRunningBusData(
                                sourceLocationId, destinationLocationId);
                            if (sourceLocationController.text.isNotEmpty &&
                                destinationLocationController.text.isNotEmpty) {
                              _saveSearch(
                                  sourceLocationController.text,
                                  destinationLocationController.text,
                                  sourceLocationId ?? -1,
                                  destinationLocationId ?? -1);
                            }
                            _sourceFocusNode.unfocus();
                            _destinationFocusNode.unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Search Bus",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                ],
              ),
            ),
            Expanded(
              child: isLoading ? _buildLoadingSkeleton() : _buildBusList(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search Using",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NMMT_BusNumberSearchScreen(),
                            ),
                          );
                        },
                        child: _buildSearchOption(
                            Icons.numbers_rounded, "Bus Number"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NMMT_BusStopSearchScreen(),
                            ),
                          );
                        },
                        child: _buildSearchOption(
                            Icons.directions_bus, "Bus Stop"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOption(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    if (isLoading) {
      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (context, index) => const SizedBox(height: 30),
              itemBuilder: (context, index) => busSkeleton(),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildBusList() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: busDataList?.length ?? 0,
            itemBuilder: (context, index) {
              final busData = busDataList![index];
              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                onTap: () async {
                  if (busData["BusRunningStatus"] == "Running") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMT_BusRouteScreen(
                          routeid:
                              int.parse(busData["RouteId"].toString() ?? ""),
                          busName: busData["RouteName"],
                          busTripId: busData["TripId"],
                          busArrivalTime: busData["ETATime"],
                          routeNo: busData["RouteNo"],
                        ),
                      ),
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Bus is Scheduled'),
                          content: const Text(
                              'Currently, you can view the route, but unfortunately, real-time bus tracking is not available.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Okay, View Route',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NMMT_BusRouteScreen(
                          routeid:
                              int.parse(busData["RouteId"].toString() ?? ""),
                          busName: busData["RouteName"],
                        ),
                      ),
                    );
                  }
                },
                leading: SizedBox(
                  width: 75,
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_bus,
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          busData['RouteNo'],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(busData['RouteName'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${busData['BusRunningStatus']}',
                      style: TextStyle(
                        color: busData['BusRunningStatus'] == 'Running'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text('Bus No: ${busData['BusNo']}'),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${busData['ETATimeMinute']} min',
                      style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('${busData['ArrivalTime']}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget busSkeleton() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(
                height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  const SizedBox(height: 5),
                  Skeleton(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Skeleton(
                height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedRoutesBottomSheetContent extends StatefulWidget {
  final List<Map<String, dynamic>> savedRoutes;
  final Function(Map<String, dynamic>) onRouteSelected;
  final Function(int, VoidCallback) onRouteDeleted;
  final Function(VoidCallback) onClearAllRoutes;

  const _SavedRoutesBottomSheetContent({
    Key? key,
    required this.savedRoutes,
    required this.onRouteSelected,
    required this.onRouteDeleted,
    required this.onClearAllRoutes,
  }) : super(key: key);

  @override
  _SavedRoutesBottomSheetContentState createState() =>
      _SavedRoutesBottomSheetContentState();
}

class _SavedRoutesBottomSheetContentState
    extends State<_SavedRoutesBottomSheetContent> {
  late List<Map<String, dynamic>> _savedRoutes;

  @override
  void initState() {
    super.initState();
    _savedRoutes = List.from(widget.savedRoutes);
  }

  void _handleRouteDeletion(int index) {
    widget.onRouteDeleted(index, () {
      setState(() {
        _savedRoutes = List.from(widget.savedRoutes);
      });
    });
  }

  void _handleClearAll() {
    widget.onClearAllRoutes(() {
      setState(() {
        _savedRoutes = List.from(widget.savedRoutes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Saved Routes",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (_savedRoutes.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all,
                            color: Colors.redAccent),
                        label: const Text('Clear All',
                            style: TextStyle(color: Colors.redAccent)),
                        onPressed: () {
                          _handleClearAll();
                        },
                      ),
                  ],
                ),
              ),
              _savedRoutes.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _savedRoutes.length,
                        separatorBuilder: (context, index) => Divider(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final savedRoute = _savedRoutes[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.directions_bus,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              '${savedRoute['source']} to ${savedRoute['destination']}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () {
                                _handleRouteDeletion(index);
                              },
                            ),
                            onTap: () {
                              widget.onRouteSelected(savedRoute);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Saved Routes Yet",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Save your favorite routes for quick access",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentSearchesBottomSheetContent extends StatefulWidget {
  final List<Map<String, dynamic>> recentSearches;
  final Function(Map<String, dynamic>) onSearchSelected;
  final Function(VoidCallback) onClearAllSearches;

  const _RecentSearchesBottomSheetContent({
    Key? key,
    required this.recentSearches,
    required this.onSearchSelected,
    required this.onClearAllSearches,
  }) : super(key: key);

  @override
  _RecentSearchesBottomSheetContentState createState() =>
      _RecentSearchesBottomSheetContentState();
}

class _RecentSearchesBottomSheetContentState
    extends State<_RecentSearchesBottomSheetContent> {
  late List<Map<String, dynamic>> _recentSearches;

  @override
  void initState() {
    super.initState();
    _recentSearches = List.from(widget.recentSearches);
  }

  void _handleClearAll() {
    widget.onClearAllSearches(() {
      setState(() {
        _recentSearches = List.from(widget.recentSearches);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Searches",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (_recentSearches.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all,
                            color: Colors.redAccent),
                        label: const Text('Clear All',
                            style: TextStyle(color: Colors.redAccent)),
                        onPressed: () {
                          _handleClearAll();
                        },
                      ),
                  ],
                ),
              ),
              _recentSearches.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _recentSearches.length,
                        separatorBuilder: (context, index) => Divider(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final recentSearch = _recentSearches[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.history,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              '${recentSearch['source']} to ${recentSearch['destination']}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            onTap: () {
                              widget.onSearchSelected(recentSearch);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Recent Searches Yet",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your recent searches will appear here",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
