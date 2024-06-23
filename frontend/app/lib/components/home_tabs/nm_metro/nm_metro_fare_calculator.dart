import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/config/api_endpoints.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NM_MetroFareCalculator extends StatefulWidget {
  List<dynamic>? metroStationsList;

  NM_MetroFareCalculator({this.metroStationsList});

  @override
  State<NM_MetroFareCalculator> createState() =>
      _NM_MetroFareCalculatorState();
}

class _NM_MetroFareCalculatorState extends State<NM_MetroFareCalculator> {
  List<dynamic>? metroStationsList;
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  String? sourceMetroStation;
  String? destinationMetroStation;

  @override
  void initState() {
    super.initState();
    _fetchMetroStations();
  }

  void _fetchMetroStations() async {
    if(widget.metroStationsList != null){
      setState(() {
        metroStationsList = widget.metroStationsList;
      });
    } else {
      final response = await http.get(
          Uri.parse(NM_MetroApiEndpoints.GetStations));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          metroStationsList = data;
        });
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    }
  }

  double calculateFare(double distance) {
    if (distance <= 2) {
      return 10;
    } else if (distance <= 4) {
      return 15;
    } else if (distance <= 6) {
      return 20;
    } else if (distance <= 8) {
      return 25;
    } else if (distance <= 10) {
      return 30;
    } else {
      return 40;
    }
  }

  double calculateTotalDistanceBetweenStations(
      int sourceStationID, int destinationStationID) {
    if (metroStationsList == null) {
      return 0.0; // or handle this case according to your requirements
    }

    double totalDistance = 0.0;
    bool countingDistance = false;

    if(sourceStationID > destinationStationID) {
      for(var station in metroStationsList!.reversed) {
        if(int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) == sourceStationID || int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) == destinationStationID) {
          countingDistance = !countingDistance;
        }

        if(countingDistance) {
          totalDistance += station['distance']['fromPreviousStation'];
        }

        if(station['stationID'] == destinationStationID) {
          break;
        }
      }
    }else{
      for(var station in metroStationsList!) {
        if(int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) == sourceStationID || int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) == destinationStationID) {
          countingDistance = !countingDistance;
        }

        if(countingDistance) {
          totalDistance += station['distance']['toNextStation'];
        }

        if(int.parse(station['stationID'].replaceAll(RegExp(r'[^0-9]'), '')) == destinationStationID) {
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
              color: Colors.orange,
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
                        color: Colors.orange,
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
                    return metroStationsList
                        ?.where((station) =>
                    station?['stationName']['English']
                        ?.toLowerCase()
                        ?.contains(pattern.toLowerCase()) ??
                        false ||
                            station?['stationName']['Marathi']
                                ?.toLowerCase()
                                ?.contains(pattern.toLowerCase()) ??
                        false)
                        .toList() ??
                        [];
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(4),
                      leading: Image.asset('assets/icons/NM_Metro.png', width: 30),
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
                        color: Colors.orange,
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
                    return metroStationsList
                        ?.where((station) =>
                    station?['stationName']['English']
                        ?.toLowerCase()
                        ?.contains(pattern.toLowerCase()) ??
                        false ||
                            station?['stationName']['Marathi']
                                ?.toLowerCase()
                                ?.contains(pattern.toLowerCase()) ??
                        false)
                        .toList() ??
                        [];
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(4),
                      leading: Image.asset('assets/icons/NM_Metro.png', width: 30),
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
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            onPressed: () {
              if (sourceMetroStation != null &&
                  destinationMetroStation != null) {
                String sourceStationID = metroStationsList!
                    .firstWhere((station) =>
                station['stationName']['English'] == sourceMetroStation)['stationID'];

                String destinationStationID = metroStationsList!
                    .firstWhere((station) =>
                station['stationName']['English'] == destinationMetroStation)['stationID'];

                double totalDistance =
                calculateTotalDistanceBetweenStations(
                    int.parse(sourceStationID.replaceAll(RegExp(r'[^0-9]'), '')), int.parse(destinationStationID.replaceAll(RegExp(r'[^0-9]'), '')));
                double fare = calculateFare(totalDistance);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Fare Calculation',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text('You are traveling from:'),
                            SizedBox(height: 5),
                            Text('$sourceMetroStation to $destinationMetroStation'),
                            SizedBox(height: 5),
                            Text('Distance: ~ ${totalDistance.toStringAsFixed(2)} km'),
                            SizedBox(height: 15),
                            Text('The fare for your journey is:'),
                            SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: 'Rs. $fare',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text('OK', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

              }
            },
            child: Text('Calculate Fare', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
