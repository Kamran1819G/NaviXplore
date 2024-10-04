import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/nm_metro_controller.dart';
import 'package:quickalert/quickalert.dart';

class NM_MetroFareCalculator extends StatefulWidget {
  NM_MetroFareCalculator({Key? key}) : super(key: key);

  @override
  State<NM_MetroFareCalculator> createState() => _NM_MetroFareCalculatorState();
}

class _NM_MetroFareCalculatorState extends State<NM_MetroFareCalculator> {
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  String? sourceMetroStation;
  String? destinationMetroStation;

  final NMMetroController controller = Get.find<NMMetroController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await controller.fetchAllStations();
  }

  double calculateTotalDistanceBetweenStations(
      int sourceStationID, int destinationStationID) {
    double totalDistance = 0.0;
    bool countingDistance = false;

    if (sourceStationID > destinationStationID) {
      for (var station in controller.allMetroStations.reversed) {
        if (int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) ==
                sourceStationID ||
            int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) ==
                destinationStationID) {
          countingDistance = !countingDistance;
        }

        if (countingDistance) {
          totalDistance += station['distance']['fromPreviousStation'];
        }

        if (station['stationID'] == destinationStationID) {
          break;
        }
      }
    } else {
      for (var station in controller.allMetroStations) {
        if (int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) ==
                sourceStationID ||
            int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) ==
                destinationStationID) {
          countingDistance = !countingDistance;
        }

        if (countingDistance) {
          totalDistance += station['distance']['toNextStation'];
        }

        if (int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) ==
            destinationStationID) {
          break;
        }
      }
    }

    return totalDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NM Metro Fare Calculator'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ready to explore the metro journey? Plan your journey and check your ticket fare!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                // Source Station Search Box
                TypeAheadField<dynamic>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: sourceLocationController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            sourceLocationController.clear();
                            sourceMetroStation = null;
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.grey),
                      ),
                      hintText: "Source Metro Station",
                      border: InputBorder.none,
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return controller.allMetroStations
                        .where((station) =>
                            station['stationName']['English']
                                ?.toLowerCase()
                                ?.contains(pattern.toLowerCase()) ??
                            false ||
                                station['stationName']['Marathi']
                                    ?.toLowerCase()
                                    ?.contains(pattern.toLowerCase()) ??
                            false)
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(4),
                      leading:
                          Image.asset('assets/icons/NM_Metro.png', width: 30),
                      title: Text(suggestion['stationName']['English']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      sourceLocationController.text =
                          suggestion['stationName']['English'];
                      sourceMetroStation = suggestion['stationName']['English'];
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Destination Station Search Box
                TypeAheadField<dynamic>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: destinationLocationController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            destinationLocationController.clear();
                            destinationMetroStation = null;
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.grey),
                      ),
                      hintText: "Destination Metro Station",
                      border: InputBorder.none,
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return controller.allMetroStations
                            .where((station) =>
                                station['stationName']['English']
                                    ?.toLowerCase()
                                    ?.contains(pattern.toLowerCase()) ??
                                false ||
                                    station['stationName']['Marathi']
                                        ?.toLowerCase()
                                        ?.contains(pattern.toLowerCase()) ??
                                false)
                            .toList() ??
                        [];
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(4),
                      leading:
                          Image.asset('assets/icons/NM_Metro.png', width: 30),
                      title: Text(suggestion['stationName']['English']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      destinationLocationController.text =
                          suggestion['stationName']['English'];
                      destinationMetroStation =
                          suggestion['stationName']['English'];
                    });
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            onPressed: () {
              if (sourceMetroStation != null &&
                  destinationMetroStation != null) {
                String sourceStationID = controller.allMetroStations.firstWhere(
                    (station) =>
                        station['stationName']['English'] ==
                        sourceMetroStation)['stationID'];

                String destinationStationID = controller.allMetroStations
                    .firstWhere((station) =>
                        station['stationName']['English'] ==
                        destinationMetroStation)['stationID'];

                double totalDistance = calculateTotalDistanceBetweenStations(
                    int.parse(
                        sourceStationID.replaceAll(RegExp(r'[^0-9]'), '')),
                    int.parse(destinationStationID.replaceAll(
                        RegExp(r'[^0-9]'), '')));
                double fare = controller.calculateFare(totalDistance);

                QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    title: 'Fare Calculation',
                    confirmBtnText: 'OK',
                    confirmBtnColor: Theme.of(context).primaryColor,
                    confirmBtnTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    barrierDismissible: false,
                    widget: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('From:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(sourceLocationController.text),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('To:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(destinationLocationController.text),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Distance:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('~${totalDistance.toStringAsFixed(2)} km'),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fare:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Rs. $fare',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ));
              }
            },
            child:
                Text('Calculate Fare', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
