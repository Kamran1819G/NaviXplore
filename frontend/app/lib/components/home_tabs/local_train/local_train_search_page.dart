import 'package:flutter/material.dart';

class LocalTrainSearchPage extends StatefulWidget {
  const LocalTrainSearchPage({super.key});

  @override
  State<LocalTrainSearchPage> createState() => _LocalTrainSearchPageState();
}

class _LocalTrainSearchPageState extends State<LocalTrainSearchPage> {
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
              "Search Local Trains",
              style: TextStyle(color: Colors.black),
            )),
        body:
            ListView(padding: EdgeInsets.symmetric(horizontal: 20), children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Source Station Search Box
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(
                        width: 1, color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.start,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Source Station",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
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
                SizedBox(height: 10),
                // Destination Station Search Box
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.last_page,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Destination Station",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
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
              ],
            ),
          ),
          Divider(
            height: 10,
            thickness: 2,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Text(
                "Recently Searched",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ]),
          ),
          ListTile(
            splashColor: Theme.of(context).primaryColor,
            focusColor: Theme.of(context).primaryColor,
            contentPadding: EdgeInsets.all(16),
            onTap: () {
              // Handle tile click
            },
            leading: Icon(
              Icons.train,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              "SourceStation",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "DestinationStation",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(
              Icons.arrow_forward,
              color: Colors.black,
            ),
          ),
        ]));
  }
}
