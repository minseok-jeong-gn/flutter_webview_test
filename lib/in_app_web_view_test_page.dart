import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

WebViewEnvironment? webViewEnvironment;

class InAppWebViewTestPage extends StatefulWidget {
  const InAppWebViewTestPage({super.key});

  @override
  State<InAppWebViewTestPage> createState() => _InAppWebViewTestPageState();
}

class _InAppWebViewTestPageState extends State<InAppWebViewTestPage> {
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text("JavaScript Handlers")),
          body: SafeArea(
              child: Column(children: <Widget>[
            Expanded(
              child: InAppWebView(
                webViewEnvironment: webViewEnvironment,
                initialSettings: settings,
                onWebViewCreated: (controller) async {
                  await controller.platform.clearAllCache();

                  controller.addJavaScriptHandler(
                    handlerName: 'getDeviceInfo',
                    callback: (_) async {
                      late final BaseDeviceInfo deviceInfo;
                      if (Platform.isAndroid) {
                        deviceInfo = await DeviceInfoPlugin().androidInfo;
                      } else {
                        deviceInfo = await DeviceInfoPlugin().iosInfo;
                      }
                      return deviceInfo.data;
                    },
                  );

                  const benchMarkTestWebSite = 'https://browserbench.org/';
                  const localTestWebsite = 'http://192.168.50.147:8080/index.html';
                  controller.loadUrl(urlRequest: URLRequest(url: WebUri(benchMarkTestWebSite)));
                },
                onConsoleMessage: (controller, consoleMessage) {
                  log(consoleMessage.toString());
                },
              ),
            ),
          ]))),
    );
  }
}
