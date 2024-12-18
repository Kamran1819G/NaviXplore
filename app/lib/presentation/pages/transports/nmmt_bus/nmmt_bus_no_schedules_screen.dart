import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:navixplore/core/utils/api_endpoints.dart';
import 'package:xml/xml.dart' as xml;

class NMMT_BusNumberSchedulesScreen extends StatefulWidget {
  final int routeid;
  final String busName;
  final int stationid;
  final String busStopName;

  const NMMT_BusNumberSchedulesScreen({
    Key? key,
    required this.routeid,
    required this.busName,
    required this.busStopName,
    required this.stationid,
  }) : super(key: key);

  @override
  State<NMMT_BusNumberSchedulesScreen> createState() =>
      _NMMT_BusNumberSchedulesScreenState();
}

class _NMMT_BusNumberSchedulesScreenState
    extends State<NMMT_BusNumberSchedulesScreen> {
  List<dynamic>? busScheduleDataList;
  final ScrollController _scrollController = ScrollController();
  int? nextBusIndex;

  @override
  void initState() {
    super.initState();
    _fetchBusScheduleData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime parseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (parts[1] == 'AM' && hour == 12) {
      return DateTime(0, 1, 1, 0, minute); // Midnight case
    } else if (parts[1] == 'PM' && hour != 12) {
      return DateTime(0, 1, 1, hour + 12, minute); // PM case
    } else {
      return DateTime(0, 1, 1, hour, minute); // AM or noon case
    }
  }

  void _fetchBusScheduleData() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${NMMTApiEndpoints.GetBusScheduleForRoute}?RouteId=${widget.routeid}&StationID=${widget.stationid}',
      );

      if (response.statusCode == 200) {
        if (xml.XmlDocument.parse(response.data)
                .innerText
                .trim()
                .toUpperCase() ==
            "NO DATA FOUND") {
          setState(() {
            busScheduleDataList = [];
          });
        } else {
          final List<dynamic> busSchedule =
              json.decode(xml.XmlDocument.parse(response.data).innerText);

          busSchedule.sort((a, b) {
            final timeA = parseTime(a['TripStartTime']);
            final timeB = parseTime(b['TripStartTime']);
            return timeA.compareTo(timeB);
          });

          final uniqueBusSchedule = <dynamic>[];
          for (final schedule in busSchedule) {
            if (!uniqueBusSchedule.any(
                (item) => item['TripStartTime'] == schedule['TripStartTime'])) {
              uniqueBusSchedule.add(schedule);
            }
          }

          setState(() {
            busScheduleDataList = uniqueBusSchedule;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToNextBus();
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _scrollToNextBus() {
    if (busScheduleDataList == null || busScheduleDataList!.isEmpty) return;

    final now = DateTime.now();
    final currentTime = DateTime(0, 1, 1, now.hour, now.minute);

    int index = busScheduleDataList!.indexWhere((schedule) {
      final scheduleTime = parseTime(schedule['TripStartTime']);
      return scheduleTime.isAfter(currentTime);
    });

    if (index == -1) {
      index = busScheduleDataList!.length - 1; // Last bus if no next bus found
    }

    setState(() {
      nextBusIndex = index;
    });

    _scrollController.animateTo(
      index * 80.0, // Adjust this value based on the actual height of each item
      duration: Duration(seconds: 2),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (busScheduleDataList == null) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: const BackButton(
              color: Colors.black,
            ),
            title: Text(
              widget.busStopName,
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 10),
                Text(
                  'Fetching bus schedule...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ));
    } else if (busScheduleDataList!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: Text(
            widget.busStopName,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Center(
          child: Text(
            '😢 No bus schedule for this route.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: Text(
            widget.busStopName,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: busScheduleDataList!.length,
          itemBuilder: (context, index) {
            final schedule = busScheduleDataList![index];
            final isNextBus = index == nextBusIndex;
            return ListTile(
              tileColor: isNextBus
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : null,
              contentPadding: EdgeInsets.all(10),
              visualDensity: VisualDensity.compact,
              leading: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    schedule['TripStartTime'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: Text(widget.busName)),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}
