import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/components/home_tabs/nm_metro/nm_metro_route_page.dart';
import 'package:navixplore/config/api_endpoints.dart';

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
    final response = await http.get(Uri.parse(
        NM_MetroApiEndpoints.GetUpcomingTrains(
            widget.lineID, direction, widget.stationID)));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        upcomingTrains = data;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToNextMetro();
      });
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
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
                ? Center(child: CircularProgressIndicator())
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
}
