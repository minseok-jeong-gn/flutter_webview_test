import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

const benchMarkTestWebSiteUrl = 'https://browserbench.org/';

class WebviewPerformanceTestPage extends StatefulWidget {
  const WebviewPerformanceTestPage({super.key});

  @override
  State<WebviewPerformanceTestPage> createState() => _WebviewPerformanceTestPageState();
}

class _WebviewPerformanceTestPageState extends State<WebviewPerformanceTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webview PerformanceTest'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _PerfTestFlutterInAppWebView()));
            },
            child: const Text('flutter_inappwebview'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _PeftTestWebViewFlutter()));
              },
              child: const Text('webview_flutter')),
        ],
      ),
    );
  }
}

class _PerfTestFlutterInAppWebView extends StatelessWidget {
  const _PerfTestFlutterInAppWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_inappwebview')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(benchMarkTestWebSiteUrl),
        ),
        onWebViewCreated: (controller) {
          controller.getSettings().then((v) {
            log('flutter_inappwebview user-agnet info:\n${v?.userAgent}');
          });
        },
      ),
    );
  }
}

class _PeftTestWebViewFlutter extends StatefulWidget {
  const _PeftTestWebViewFlutter({super.key});

  @override
  State<_PeftTestWebViewFlutter> createState() => _PeftTestWebViewFlutterState();
}

class _PeftTestWebViewFlutterState extends State<_PeftTestWebViewFlutter> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(benchMarkTestWebSiteUrl))
      ..setOnConsoleMessage((javascriptConsoleMessage) {
        log(javascriptConsoleMessage.toString());
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller.getUserAgent().then((v) {
      log('webview_flutter user-agnet info:\n$v');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('webview_flutter')),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
