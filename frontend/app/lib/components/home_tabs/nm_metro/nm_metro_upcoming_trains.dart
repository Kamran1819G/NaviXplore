import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_route_page.dart';
import 'package:navixplore/services/firebase/firestore_service.dart';
import 'package:navixplore/widgets/Skeleton.dart';

class NM_MetroUpcomingTrains extends StatefulWidget {
  final String lineID;
  final String stationID;
  final String stationName;

  NM_MetroUpcomingTrains({
    required this.lineID,
    required this.stationID,
    required this.stationName,
  });

  @override
  _NM_MetroUpcomingTrainsState createState() => _NM_MetroUpcomingTrainsState();
}

class _NM_MetroUpcomingTrainsState extends State<NM_MetroUpcomingTrains> {
  Map<String, dynamic>? upcomingTrains;
  String direction = "up";
  final ScrollController _scrollController = ScrollController();
  int? nextMetroIndex;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingTrains();
  }


  Future<void> _fetchUpcomingTrains() async {
    try {
      final QuerySnapshot upcomingTrainsSnapshot = await FirestoreService().getDocumentWithMultipleFilter(
        collection: "NM-Metro-Schedules",
        filters: [
          {'field': 'lineID', 'value': widget.lineID},
          {'field': 'direction', 'value': direction},
        ],
      );

      if (upcomingTrainsSnapshot.docs.isNotEmpty) {
        final QueryDocumentSnapshot firstDocument = upcomingTrainsSnapshot.docs.first;
        final Map<String, dynamic> data = firstDocument.data() as Map<String, dynamic>;

        // Extract the specific schedule for the stationID
        final List<dynamic> schedules = data['schedules'] as List<dynamic>;
        final stationSchedule = schedules.firstWhere(
              (s) => s['stationID'] == widget.stationID,
          orElse: () => null,
        );

        if (stationSchedule != null) {
          setState(() {
            upcomingTrains = {
              'lineID': data['lineID'],
              'trainName': data['trainName'],
              'stationID': stationSchedule['stationID'],
              'upcomingTimes': stationSchedule['time'],
            };
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToNextMetro();
          });
        } else {
          if (kDebugMode) {
            print("No schedule found for the specified stationID.");
          }
          setState(() {
            upcomingTrains = null;
          });
        }
      } else {
        if (kDebugMode) {
          print("No schedules found for the specified lineID and direction.");
        }
        setState(() {
          upcomingTrains = null;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching upcoming trains: $e");
      }
      setState(() {
        upcomingTrains = null;
      });
    }
  }



  String _formatTime(String time24) {
    final DateFormat inputFormat = DateFormat.Hm();
    final DateFormat outputFormat = DateFormat.jm();
    final DateTime dateTime = inputFormat.parse(time24);
    return outputFormat.format(dateTime);
  }

  void _scrollToNextMetro() {
    if (upcomingTrains != null) {
      final currentTime = DateTime.now();
      final upcomingTimes = upcomingTrains!['upcomingTimes'];
      for (int i = 0; i < upcomingTimes.length; i++) {
        final time = _formatTime(upcomingTimes[i]);
        final time24 = upcomingTimes[i];
        final timeParts = time24.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final timeToCompare = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          hour,
          minute,
        );
        if (timeToCompare.isAfter(currentTime)) {
          setState(() {
            nextMetroIndex = i;
          });
          _scrollController.animateTo(
            i * 95.0,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
          );
          break;
        }
      }
    }
  }

  void _onDirectionChanged(String newDirection) {
    if (direction != newDirection) {
      setState(() {
        direction = newDirection;
        _fetchUpcomingTrains();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stationName),
      ),
      body: Column(
        children: [
          _buildDirectionSelector(),
          Expanded(
            child: upcomingTrains == null
                ? _buildSkeleton()
                : ListView.builder(
              controller: _scrollController,
              itemCount: upcomingTrains!['upcomingTimes'].length,
              itemBuilder: (context, index) {
                final isNextMetro = index == nextMetroIndex;
                return ListTile(
                  tileColor: isNextMetro ? Colors.orange.withOpacity(0.2) : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NM_MetroRoutePage(
                          lineID: widget.lineID,
                          direction: direction,
                          trainName: upcomingTrains!['trainName'],
                          trainNo: index,
                        ),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  title: Text(
                    direction == "up" ? "Pendhar" : "Belapur Terminals",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    upcomingTrains!['trainName'],
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  trailing: Text(
                    _formatTime(upcomingTrains!['upcomingTimes'][index]),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionSelector() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDirectionButton("up", "Pendhar", Icons.arrow_upward),
          _buildDirectionButton("down", "Belapur Terminals", Icons.arrow_downward),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(String dir, String label, IconData icon) {
    final bool isSelected = direction == dir;
    return GestureDetector(
      onTap: () => _onDirectionChanged(dir),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(width: 2, color: Colors.orange),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.orange,
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Skeleton(height: 50, width: 50),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Skeleton(height: 8, width: 100),
          ),
          subtitle: Skeleton(height: 8, width: 50),
        );
      },
    );
  }
}
