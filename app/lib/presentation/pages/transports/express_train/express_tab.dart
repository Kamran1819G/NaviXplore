import 'package:flutter/material.dart';
import 'package:navixplore/presentation/widgets/webview_screen.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class ExpressTab extends StatefulWidget {
  const ExpressTab({Key? key}) : super(key: key);

  @override
  State<ExpressTab> createState() => _ExpressTabState();
}

class _ExpressTabState extends State<ExpressTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () async {
            await LaunchApp.openApp(
              androidPackageName: "cris.org.in.prs.ima",
              openStore: true,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/IRCTC.png",
                            width: 40, height: 40),
                        const SizedBox(width: 14),
                        const Text(
                          "BOOK TICKET",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      "Open IRCTC App",
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).primaryColor),
                    ),
                  ],
                )),
          ),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebView_Screen(
                      url:
                          "https://www.indianrail.gov.in/enquiry/PNR/PnrEnquiry.html?locale=en",
                      title: "PNR Status",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Image.asset("assets/images/pnr_status.png", height: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "PNR Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebView_Screen(
                      url:
                          "https://www.indianrail.gov.in/enquiry/FARE/FareEnquiry.html?locale=en",
                      title: "Fare Enquiry",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.currency_rupee, size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Fare Enquiry",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebView_Screen(
                      url:
                          "https://www.indianrail.gov.in/enquiry/SCHEDULE/TrainSchedule.html",
                      title: "Train Schedule",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Image.asset("assets/images/schedule.png", height: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Time Table",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebView_Screen(
                      url:
                          "https://www.indianrail.gov.in/enquiry/SEAT/SeatAvailability.html?locale=en",
                      title: "Seat Availability",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.airline_seat_recline_normal, size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Seat Availability",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
