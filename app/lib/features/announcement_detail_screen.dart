import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppSpaces {
  static const smallVerticalSpace = SizedBox(height: 8.0);
  static const mediumVerticalSpace = SizedBox(height: 16.0);
  static const largeVerticalSpace = SizedBox(height: 24.0);
}

const commonPadding = EdgeInsets.symmetric(horizontal: 10);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Theme.of(context).primaryColor,
        ),
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
              child: AspectRatio(
                  aspectRatio: 16/9,
                  child: CachedNetworkImage(
                    imageUrl: announcement['imageUrl'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )),
            ),
            AppSpaces.mediumVerticalSpace,
            Padding(
              padding: commonPadding,
              child: Text(
                announcement['title'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpaces.smallVerticalSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                announcement['description'],
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            AppSpaces.smallVerticalSpace,
            const Divider(height: 1),
            Padding(
              padding: commonPadding,
              child: Text(
                formattedDate,
                style: const TextStyle(
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