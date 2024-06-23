import 'package:flutter/material.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({super.key});

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  String dropdownValue = "low";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text("Report an Issue", style: TextStyle(color: Colors.orange),),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Navi", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 60)),
                Text("X", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 75)),
                Text("plore", style: TextStyle(color: Colors.orange, fontFamily: "Fredoka", fontWeight: FontWeight.bold, fontSize: 60)),
              ],
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text("Thank you for taking your valuable time and giving your input to shape up the app. Please share your feedback in below form.."),
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                    controller: TextEditingController(),
                    obscureText: false,
                    decoration: const InputDecoration(
                      label: Text("Full Name"),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                    )
                )
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      label: Text("email@address.com"),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                    )
                )
            ),
            const SizedBox(height: 25),
            DropdownButtonFormField<String>(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const InputDecoration(
                label: Text("Criticality Level"),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              value: dropdownValue,
              items: const [
                DropdownMenuItem<String>(value: 'high',child: Text("High")),
                DropdownMenuItem<String>(value: 'medium',child: Text("Medium")),
                DropdownMenuItem<String>(value: 'low', child: Text("Low")),
              ],
              onChanged: (String? newValue){
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                    maxLines: 5,
                    maxLength: 500,
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      label: Text("Describe The Issue"),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),

                    )
                )
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text("Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
