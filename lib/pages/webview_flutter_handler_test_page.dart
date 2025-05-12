import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../enums/test_website.dart';
import '../js_message_handlers/check_permission_handler.dart';
import '../js_message_handlers/concat_handler.dart';
import '../js_message_handlers/get_device_info_handler.dart';
import '../js_message_handlers/base/javascript_message_handler.dart';
import '../models/gn_location.dart';
import '../utils/log_util.dart';
import '../widgets/my_text.dart';

class WebviewFlutterHandlerTestPage extends StatefulWidget {
  const WebviewFlutterHandlerTestPage({super.key});

  @override
  State<WebviewFlutterHandlerTestPage> createState() => _WebviewFlutterHandlerTestPageState();
}

class _WebviewFlutterHandlerTestPageState extends State<WebviewFlutterHandlerTestPage> {
  late final WebViewController controller = WebViewController();

  final List<JavascriptMessageHandler> _javascriptMessageHandlers = [
    GetDeviceInfoHandler(),
    CheckPermissionHandler(),
    ConcatHandler(),
  ];

  late final Map<String, JavascriptMessageHandler> _handlerMap;

  late final GNLocation _currentLocation = GNLocation(latitude: 37.5503, longitude: 126.9971);

  late final Timer _fakeLocationChangeTimer;

  @override
  void initState() {
    super.initState();

    _handlerMap = Map.fromEntries(_javascriptMessageHandlers.map((x) => MapEntry(x.messageName, x)));

    final debugginEnableCompleter = Completer<void>();
    if (Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true).then((_) => debugginEnableCompleter.complete());
    } else {
      if (controller.platform case final WebKitWebViewController webKitController) {
        webKitController.setInspectable(true).then((_) => debugginEnableCompleter.complete());
      } else {
        debugginEnableCompleter.complete();
      }
    }

    debugginEnableCompleter.future.then((_) async {
      await controller.clearCache();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setOnConsoleMessage((consoleMsg) {
        Log.d(consoleMsg.message);
      });
      await controller.addJavaScriptChannel(
        'appBridgeChannel',
        onMessageReceived: (jsMessage) async {
          final jsonObj = jsonDecode(jsMessage.message);
          if (jsonObj
              case {
                'method': final String method,
                'seq': final int seq,
                'params': final Map<String, Object?> params,
              }) {
            if (_handlerMap.containsKey(method)) {
              try {
                final result = await _handlerMap[method]!.call(params, controller);
                final retVal = {
                  ...result.toJson(),
                  'seq': seq,
                  'method': method,
                };
                final javascriptCode = 'window.appBridge._onListenAppBridgeMessage(${jsonEncode(retVal)})';
                controller.runJavaScript(javascriptCode);
              } catch (error) {
                final retVal = {
                  'resultOk': false,
                  'error': error.toString(),
                  'seq': seq,
                  'method': method,
                };
                final javascriptCode = 'window.appBridge._onListenAppBridgeMessage(${jsonEncode(retVal)})';
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
      await controller.loadRequest(Uri.parse(TestWebsite.localDartShelfServerTest2.url));
      await Future.delayed(const Duration(seconds: 1));
      _fakeLocationChangeTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) {
          final javascriptCode = 'window.appBridge._onListenLocationChangeMessage(${jsonEncode(_currentLocation.toMap())})';
          controller.runJavaScript(javascriptCode);
        },
      );
    });
  }

  @override
  void dispose() {
    _fakeLocationChangeTimer.cancel();
    super.dispose();
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
