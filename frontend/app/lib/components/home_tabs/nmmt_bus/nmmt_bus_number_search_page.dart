import 'package:flutter/material.dart';
import 'package:navixplore/components/home_tabs/nmmt_bus/nmmt_bus_route_page.dart';
import 'package:navixplore/services/NMMT_Service.dart';

import '../../../widgets/Skeleton.dart';

class NMMTBusNumberSearchPage extends StatefulWidget {
  const NMMTBusNumberSearchPage({super.key});

  @override
  State<NMMTBusNumberSearchPage> createState() =>
      _NMMTBusNumberSearchPageState();
}

class _NMMTBusNumberSearchPageState extends State<NMMTBusNumberSearchPage> {
  bool isLoading = true;
  List<dynamic>? filteredBusData;
  TextEditingController _searchController = TextEditingController();

  final NMMTService _nmmtService = NMMTService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await _nmmtService.fetchAllBuses();
    setState(() {
      filteredBusData = _nmmtService.allBuses;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _searchBusNumber(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBusData = _nmmtService.allBuses;
      });
    } else {
      setState(() {
        filteredBusData = _nmmtService.allBuses
            .where((busStop) => busStop['routeName']['English']
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
                                  routeid: busData["routeID"],
                                  busName: busData["routeName"]['English']),
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
                          busData["routeName"]['English'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          busData["routeName"]['Marathi'],
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
