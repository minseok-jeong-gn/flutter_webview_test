// When webview is inside Scrollable widget (ListView, SingleChildScrollView) there is some issue when scrolling.
// So this test page is for test the webview that is inside the scrollable widget.
// Should test each of Hybrid Composition, Texture Layer Hybrid Composition.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/my_text.dart';

class WebviewScrollTestPage extends StatefulWidget {
  const WebviewScrollTestPage({super.key});

  @override
  State<WebviewScrollTestPage> createState() => _WebviewScrollTestPageState();
}

class _WebviewScrollTestPageState extends State<WebviewScrollTestPage> {
  final controllerList = List<WebViewController>.generate(
    4,
    (index) => WebViewController(),
  );

  @override
  void initState() {
    super.initState();
    for (final controller in controllerList) {
      controller.loadRequest(Uri.parse('https://naver.com'));
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(
        title: const Text('Webview Scroll Test'),
        actions: [
          TextButton(
            onPressed: () {},
            child: MyText.small('webview_flutter(HC)'),
          ),
          TextButton(
            onPressed: () {},
            child: MyText.small('webview_flutter(TLHC)'),
          ),
          TextButton(
            onPressed: () {},
            child: MyText.small('flutter_inappwebview(HC)'),
          ),
          TextButton(
            onPressed: () {},
            child: MyText.small('flutter_inappwebview(TLHC)'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (true)
              for (final controller in controllerList) ...[
                Container(
                  height: 300.0,
                  width: double.infinity,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 500,
                  child: WebViewWidget(
                    controller: controller,
                    gestureRecognizers: {
                      // Allow vertical scrolling WITHIN the WebView
                      Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ),
                      // Allow horizontal scrolling/panning WITHIN the WebView
                      Factory<HorizontalDragGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer(),
                      ),
                      // Optional: Allow pinch-zoom WITHIN the WebView content
                      Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer(),
                      ),
                    },
                  ),
                ),
              ]
            else
              for (int i = 0; i < 5; i++) ...[
                Container(
                  height: 300.0,
                  width: double.infinity,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 600,
                  child: InAppWebView(
                    keepAlive: InAppWebViewKeepAlive(),
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://map.naver.com'),
                    ),
                    gestureRecognizers: {
                      // Allow vertical scrolling WITHIN the WebView
                      Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ),
                      // Allow horizontal scrolling/panning WITHIN the WebView
                      Factory<HorizontalDragGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer(),
                      ),
                      // Optional: Allow pinch-zoom WITHIN the WebView content
                      Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer(),
                      ),
                    },
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _WebViewFlutterScrollTestWidget extends StatefulWidget {
  const _WebViewFlutterScrollTestWidget();

  @override
  State<_WebViewFlutterScrollTestWidget> createState() => _WebViewFlutterScrollTestWidgetState();
}

class _WebViewFlutterScrollTestWidgetState extends State<_WebViewFlutterScrollTestWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
