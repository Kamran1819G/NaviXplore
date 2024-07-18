import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:navixplore/services/NM_Metro_Service.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';

class NM_MetroFareCalculator extends StatefulWidget {

  NM_MetroFareCalculator({Key? key}) : super(key: key);

  @override
  State<NM_MetroFareCalculator> createState() =>
      _NM_MetroFareCalculatorState();
}

class _NM_MetroFareCalculatorState extends State<NM_MetroFareCalculator> {
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  String? sourceMetroStation;
  String? destinationMetroStation;

  final NM_MetroService _nmMetroService = NM_MetroService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize () async{
    await _nmMetroService.fetchAllStations();
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
    double totalDistance = 0.0;
    bool countingDistance = false;

    if(sourceStationID > destinationStationID) {
      for(var station in _nmMetroService.allMetroStations.reversed) {
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
      for(var station in _nmMetroService.allMetroStations) {
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
                    return _nmMetroService.allMetroStations
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
                    return _nmMetroService.allMetroStations
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
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            onPressed: () {
              if (sourceMetroStation != null &&
                  destinationMetroStation != null) {
                String sourceStationID = _nmMetroService.allMetroStations
                    .firstWhere((station) =>
                station['stationName']['English'] == sourceMetroStation)['stationID'];

                String destinationStationID = _nmMetroService.allMetroStations
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
                                  color: Theme.of(context).primaryColor,
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
                                backgroundColor: Theme.of(context).primaryColor,
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
