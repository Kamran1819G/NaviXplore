import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  TermsAndConditionsScreen({Key? key}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: 12/31/2024',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            MarkdownBody(
              selectable: true,
              data: "### yet to Implement",
            ),
          ],
        ),
      ),
    );
  }
}
