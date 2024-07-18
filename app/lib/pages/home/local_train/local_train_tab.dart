import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:navixplore/pages/home/local_train/local_train_penalties.dart';
import 'package:navixplore/pages/home/local_train/local_train_search_page.dart';
import 'package:navixplore/widgets/webview_screen.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class LocalTrainTab extends StatefulWidget {
  const LocalTrainTab({super.key});

  @override
  State<LocalTrainTab> createState() => _LocalTrainTabState();
}

class _LocalTrainTabState extends State<LocalTrainTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Search Box
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalTrainSearchPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(width: 1, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.train_style_two,
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter destination station",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),

        // Nearest Local Station
        const Column(
          children: [
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nearest Local Station",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.train, size: 40),
                    SizedBox(width: 5),
                    Text("Kharghar Station"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.directions, size: 25),
                    Text("6 km"),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        // Related to Metro
        Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Related to Locals",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.currency_rupee_outlined, size: 40),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fare",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocalTrainPenalties(),
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
                        child: Image.asset("assets/images/Law.png"),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Local Penalties",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.explore, size: 40),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Stations",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebView_Screen(
                            url: 'https://goo.gl/maps/GCFQt1LrDKdwdQNv6',
                            title: 'Mumbai Local RailMap'),
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
                        child: Image.asset("assets/images/Map.png"),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Local Railmap",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () async {
                await LaunchApp.openApp(
                  androidPackageName: "com.cris.utsmobile",
                  iosUrlScheme: "uts://",
                  openStore: true,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
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
                            Image.asset("assets/images/UTS.png",
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
                          "Open UTS App",
                          style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    )),
              ),
            )
          ],
        ),
      ],
    );
  }
}
