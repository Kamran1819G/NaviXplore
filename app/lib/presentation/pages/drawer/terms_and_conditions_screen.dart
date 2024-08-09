// lib/presentation/screens/terms_and_conditions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/viewmodels/terms_and_conditions_viewmodel.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final TermsAndConditionsViewModel viewModel =
      Get.find<TermsAndConditionsViewModel>();

  TermsAndConditionsScreen({Key? key}) : super(key: key) {
    viewModel.fetchTermsAndConditions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (viewModel.error.value.isNotEmpty) {
          return Center(child: Text(viewModel.error.value));
        } else if (viewModel.termsAndConditions.value == null) {
          return Center(child: Text('No terms and conditions available.'));
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated: ${viewModel.termsAndConditions.value!.lastUpdated.toLocal()}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                MarkdownBody(
                  selectable: true,
                  data: viewModel.termsAndConditions.value!.content,
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
