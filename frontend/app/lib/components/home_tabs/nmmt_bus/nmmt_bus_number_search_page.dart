import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navixplore/components/home_tabs/nmmt_bus/nmmt_bus_route_page.dart';
import 'package:navixplore/config/api_endpoints.dart';
import 'package:xml/xml.dart';
import '../../../widgets/Skeleton.dart';

class NMMTBusNumberSearchPage extends StatefulWidget {
  const NMMTBusNumberSearchPage({super.key});

  @override
  State<NMMTBusNumberSearchPage> createState() =>
      _NMMTBusNumberSearchPageState();
}

class _NMMTBusNumberSearchPageState extends State<NMMTBusNumberSearchPage> {
  bool isLoading = true;
  List<dynamic>? busDataList;
  List<dynamic>? filteredBusData;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllBusData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch the response body
  void _fetchAllBusData() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse(NMMTApiEndpoints.GetRouteList));
    if (response.statusCode == 200) {
      final List<dynamic> buses =
          json.decode(XmlDocument.parse(response.body).innerText);

      setState(() {
        busDataList = buses;
        filteredBusData = busDataList;
        isLoading = false;
      });
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _searchBusNumber(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBusData = busDataList;
      });
    } else {
      setState(() {
        filteredBusData = busDataList
            ?.where((busStop) => busStop['RouteName']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          "Search NMMT Bus Number",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchBusNumber(value);
              },
              decoration: InputDecoration(
                hintText: "Enter Bus Number",
                prefixIcon: Icon(Icons.directions_bus,
                    color: Colors.orange, size: 20),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchBusNumber('');
                  },
                  icon: _searchController.text.isNotEmpty
                      ? Icon(Icons.clear, color: Colors.orange.shade800)
                      : Icon(
                    Icons.search,
                    color: Colors.orange.shade800,
                  ),
                ),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.separated(
                  itemCount: 10,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 40),
                  itemBuilder: (context, index) => busSkeleton(),
                )
                : ListView.builder(
                    itemCount: filteredBusData?.length ?? 0,
                    itemBuilder: (context, index) {
                      final busData = filteredBusData![index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NMMTBusRoutePage(
                                  routeid: busData["RouteId"],
                                  busName: busData["RouteName"]),
                            ),
                          );
                        },
                        leading: Container(
                          width: 5,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        title: Text(
                          busData["RouteName"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          busData["RouteName_M"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget busSkeleton() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: 5),
              Skeleton(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ],
          ),
          SizedBox(width: 10),
          Skeleton(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
          ),
        ],
      ),
    );
  }
}
