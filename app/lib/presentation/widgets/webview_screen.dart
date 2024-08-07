import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView_Screen extends StatefulWidget {
  final String url;
  final String? title;

  const WebView_Screen({Key? key, required this.url, this.title}) : super(key: key);

  @override
  State<WebView_Screen> createState() => _WebView_ScreenState();
}

class _WebView_ScreenState extends State<WebView_Screen> {
  late final WebViewController controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: widget.title != null
              ? Text(
            widget.title!,
            style: TextStyle(color: Colors.black),
          )
              : null,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(
                controller: controller,
              ),
              if (loadingPercentage < 100)
                LinearProgressIndicator(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  value: loadingPercentage / 100.0,
                ),
            ],
          ),
        ));
  }
}
