import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      iframeAllowFullscreen: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text("JavaScript Handlers")),
          body: SafeArea(
              child: Column(children: <Widget>[
            Expanded(
              child: InAppWebView(
                webViewEnvironment: webViewEnvironment,
                initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    </head>
    <body>
        <h1>JavaScript Handlers</h1>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                window.flutter_inappwebview.callHandler('handlerFoo')
                  .then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    console.log(JSON.stringify(result));

                    window.flutter_inappwebview
                      .callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}, result);
                });
            });
        </script>
    </body>
</html>
                      """),
                initialSettings: settings,
                onWebViewCreated: (controller) {
                  controller.addJavaScriptHandler(
                      handlerName: 'handlerFoo',
                      callback: (params) {
                        // return data to the JavaScript side!
                        return {'bar': 'bar_value', 'baz': 'baz_value'};
                      });

                  controller.addJavaScriptHandler(
                      handlerName: 'handlerFooWithArgs',
                      callback: (params) {
                        print('params: ${params.runtimeType}');
                        for (final param in params) {
                          print('${param.runtimeType}: $params');
                        }
                        // it will print:
                        // JavaScriptHandlerFunctionData{args: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}], isMainFrame: true, origin: , requestUrl: about:blank}
                      });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                  // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
                },
              ),
            ),
          ]))),
    );
  }
}
