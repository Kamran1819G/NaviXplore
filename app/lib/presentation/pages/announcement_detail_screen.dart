import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailPage({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = announcement["releaseAt"].toDate();

    String formattedDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 3,
        title: Row(
          children: [
            Text("Navi",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text("X",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
            Text("plore",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              child: Image.network(
                announcement['imageUrl'],
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                announcement['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                  decorationThickness: 3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                announcement['description'],
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 8),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
