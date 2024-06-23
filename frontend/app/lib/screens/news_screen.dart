import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {

  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return NewsContainer(
          imgUrl: 'https://picsum.photos/200/300',
          headline: 'Headline $index',
          newsDescription: 'Description $index',
          newsDate: 'Date $index',
        );
      },
    );
  }
}

class NewsContainer extends StatelessWidget {
  String imgUrl;
  String headline;
  String newsDescription;
  String newsDate;

  NewsContainer({
    required this.imgUrl,
    required this.headline,
    required this.newsDescription,
    required this.newsDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imgUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                newsDescription,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                newsDate,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

