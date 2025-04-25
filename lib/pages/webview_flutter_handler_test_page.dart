import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../enums/test_website.dart';
import '../utils/log_util.dart';
import '../widgets/my_text.dart';

class JsMessageHandlerResult {
  const JsMessageHandlerResult({
    required this.resultOk,
    this.data,
    this.errorMessage,
  });

  final Map<String, Object?>? data;
  final bool resultOk;
  final Object? errorMessage;

  Map<String, Object?> toJson() => {
        'data': data,
        'resultOk': resultOk,
        'errorMessage': errorMessage,
      };
}

typedef JsMessageHandler = FutureOr<JsMessageHandlerResult> Function(Map<String, Object?>? params, WebViewController controller);

class WebviewFlutterHandlerTestPage extends StatefulWidget {
  const WebviewFlutterHandlerTestPage({super.key});

  @override
  State<WebviewFlutterHandlerTestPage> createState() => _WebviewFlutterHandlerTestPageState();
}

class _WebviewFlutterHandlerTestPageState extends State<WebviewFlutterHandlerTestPage> {
  late final WebViewController controller = WebViewController();

  FutureOr<JsMessageHandlerResult> _handleGetDeviceInfo(
    Map<String, Object?>? params,
    WebViewController controller,
  ) async {
    late final BaseDeviceInfo deviceInfo;
    if (Platform.isAndroid) {
      deviceInfo = await DeviceInfoPlugin().androidInfo;
    } else {
      deviceInfo = await DeviceInfoPlugin().iosInfo;
    }

    return JsMessageHandlerResult(
      resultOk: true,
      data: deviceInfo.data,
      errorMessage: null,
    );
  }

  late final Map<String, JsMessageHandler> _messageHandler = {'getDeviceInfo': _handleGetDeviceInfo};

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
            final params = jsonObj['params'] as Map<String, Object?>?;
            if (_messageHandler.containsKey(method)) {
              try {
                final result = await _messageHandler[method]!(params, controller);
                final retVal = {
                  ...result.toJson(),
                  'seq': seq,
                  'method': method,
                };
                final javascriptCode = 'window.appBridge.onListenAppBridgeMessage(${jsonEncode(retVal)})';
                controller.runJavaScript(javascriptCode);
              } catch (error) {
                final retVal = {
                  'resultOk': false,
                  'error': error.toString(),
                  'seq': seq,
                  'method': method,
                };
                final javascriptCode = 'window.appBridge.onListenAppBridgeMessage(${jsonEncode(retVal)})';
                controller.runJavaScript(javascriptCode);
              }
            } else {
              throw Exception('Can\'t find the method: $method');
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
