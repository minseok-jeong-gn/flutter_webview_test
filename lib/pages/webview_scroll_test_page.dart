// When webview is inside Scrollable widget (ListView, SingleChildScrollView) there is some issue when scrolling.
// So this test page is for test the webview that is inside the scrollable widget.
// Should test each of Hybrid Composition, Texture Layer Hybrid Composition.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../enums/platform_view_implementation_type.dart';
import '../enums/test_website.dart';
import '../enums/web_view_test_case.dart';
import '../widgets/my_text.dart';

class WebviewScrollTestPage extends StatefulWidget {
  const WebviewScrollTestPage({super.key});

  @override
  State<WebviewScrollTestPage> createState() => _WebviewScrollTestPageState();
}

class _WebviewScrollTestPageState extends State<WebviewScrollTestPage> {
  WebViewTestCase _currentTestCase = WebViewTestCase.webViewFlutterWithHybridComposition;

  @override
  Widget build(BuildContext context) {
    const testWebsite = TestWebsite.naverMap;
    return Scaffold(
      backgroundColor: Colors.pink,
      endDrawer: Drawer(
        child: ListView(
          children: [
            for (final testCase in WebViewTestCase.values)
              if (testCase == _currentTestCase)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentTestCase = testCase;
                    });
                  },
                  child: MyText.large(testCase.shortName),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentTestCase = testCase;
                    });
                  },
                  child: MyText.small(testCase.shortName),
                ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Webview Scroll Test'),
      ),
      body: switch (_currentTestCase) {
        WebViewTestCase.webViewFlutterWithHybridComposition ||
        WebViewTestCase.webViewFlutterWithTextureLayerHybridComposition =>
          _WebViewFlutterScrollTestWidget(
            key: ValueKey(_currentTestCase),
            type: _currentTestCase.type,
            testWebsite: testWebsite,
          ),
        WebViewTestCase.flutterInAppWebViewWithHybridComposition ||
        WebViewTestCase.flutterInAppWebViewWithTextureLayerHybridComposition =>
          _FlutterInAppWebViewScrollTestWidget(
            key: ValueKey(_currentTestCase),
            type: _currentTestCase.type,
            testWebsite: testWebsite,
          ),
      },
    );
  }
}

class _WebViewFlutterScrollTestWidget extends StatefulWidget {
  const _WebViewFlutterScrollTestWidget({
    super.key,
    required this.type,
    required this.testWebsite,
  });

  final PlatformViewImplementationType type;
  final TestWebsite testWebsite;

  @override
  State<_WebViewFlutterScrollTestWidget> createState() => _WebViewFlutterScrollTestWidgetState();
}

class _WebViewFlutterScrollTestWidgetState extends State<_WebViewFlutterScrollTestWidget> {
  List<PlatformWebViewController> controllerList = List.generate(3, (_) {
    if (Platform.isAndroid) {
      return AndroidWebViewController(AndroidWebViewControllerCreationParams());
    } else {
      return WebKitWebViewController(WebKitWebViewControllerCreationParams());
    }
  });

  @override
  void initState() {
    super.initState();
    for (final controller in controllerList) {
      controller.loadRequest(LoadRequestParams(uri: Uri.parse(widget.testWebsite.url)));
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<WebViewWidget> webViewWidgets = [];
    for (final controller in controllerList) {
      late WebViewWidget webViewWidget;
      if (Platform.isAndroid) {
        webViewWidget = WebViewWidget.fromPlatformCreationParams(
          params: AndroidWebViewWidgetCreationParams(
            controller: controller,
            displayWithHybridComposition: switch (widget.type) {
              PlatformViewImplementationType.hc => true,
              PlatformViewImplementationType.tlhc => false,
            },
          ),
        );
      } else {
        webViewWidget = WebViewWidget.fromPlatformCreationParams(
          params: WebKitWebViewWidgetCreationParams(controller: controller),
        );
      }
      webViewWidgets.add(webViewWidget);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final webViewWidget in webViewWidgets) ...[
            Container(
              height: 300.0,
              width: double.infinity,
              color: Colors.red,
            ),
            SizedBox(
              height: 500,
              child: webViewWidget,
            ),
          ],
        ],
      ),
    );
  }
}

class _FlutterInAppWebViewScrollTestWidget extends StatefulWidget {
  const _FlutterInAppWebViewScrollTestWidget({
    super.key,
    required this.type,
    required this.testWebsite,
  });

  final PlatformViewImplementationType type;
  final TestWebsite testWebsite;

  @override
  State<_FlutterInAppWebViewScrollTestWidget> createState() => __FlutterInAppWebViewScrollTestWidgetState();
}

class __FlutterInAppWebViewScrollTestWidgetState extends State<_FlutterInAppWebViewScrollTestWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < 3; ++i) ...[
            Container(
              height: 300.0,
              width: double.infinity,
              color: Colors.red,
            ),
            SizedBox(
              height: 500,
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  useHybridComposition: (Platform.isAndroid)
                      ? switch (widget.type) {
                          PlatformViewImplementationType.hc => true,
                          PlatformViewImplementationType.tlhc => false,
                        }
                      : false,
                ),
                keepAlive: InAppWebViewKeepAlive(),
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.testWebsite.url),
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
    );
  }
}
