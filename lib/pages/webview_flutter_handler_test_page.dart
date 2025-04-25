import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../enums/test_website.dart';
import '../utils/log_util.dart';
import '../widgets/my_text.dart';

class WebviewFlutterHandlerTestPage extends StatefulWidget {
  const WebviewFlutterHandlerTestPage({super.key});

  @override
  State<WebviewFlutterHandlerTestPage> createState() => _WebviewFlutterHandlerTestPageState();
}

class _WebviewFlutterHandlerTestPageState extends State<WebviewFlutterHandlerTestPage> {
  late final WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true);
    }

    controller.clearCache().then((_) {
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.loadRequest(Uri.parse(TestWebsite.localDartShelfServerTest2.url));
      controller.setOnConsoleMessage((consoleMsg) {
        Log.d(consoleMsg.message);
      });

      controller.addJavaScriptChannel(
        'appBridgeChannel',
        onMessageReceived: (jsMessage) async {
          final jsonObj = jsonDecode(jsMessage.message);
          if (jsonObj
              case {
                'method': final String method,
                'seq': final int seq,
              }) {
            final params = jsonObj['params'] as Map<String, dynamic>?;
            switch (method) {
              case 'getDeviceInfo':
                late final BaseDeviceInfo deviceInfo;
                if (Platform.isAndroid) {
                  deviceInfo = await DeviceInfoPlugin().androidInfo;
                } else {
                  deviceInfo = await DeviceInfoPlugin().iosInfo;
                }

                final retVal = {
                  'seq': seq,
                  'data': deviceInfo.data,
                  'resultOk': true,
                  'method': 'getDeviceInfo',
                };

                final javascriptCode = 'window.appBridge.onListenAppBridgeMessage(${jsonEncode(retVal)})';
                controller.runJavaScript(javascriptCode);
                break;
            }
          } else {
            Log.d('Error on onMessageReceived: ${jsMessage.message}');
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyText.large('webview_flutter handler test'),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
