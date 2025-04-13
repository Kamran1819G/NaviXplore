import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String source;
  final Timestamp releaseAt;

  AnnouncementCard({
    String? imageUrl,
    String? title,
    String? description,
    String? source,
    Timestamp? releaseAt,
  })  : this.imageUrl = imageUrl ?? 'default_image_url',
        this.title = title ?? 'No Title',
        this.description = description ?? 'No Description',
        this.source = source ?? 'No Source',
        this.releaseAt = releaseAt ?? Timestamp.now();

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = releaseAt.toDate();

    String formattedDate = DateFormat.yMMMMEEEEd().format(dateTime);

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            child: Image.network(
              imageUrl,
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).primaryColor,
                decorationThickness: 3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Text(
                  formattedDate, // Display formatted date here
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Spacer(),
                Text(
                  source,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
