import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const jsSource = '''
const testConstString = 'this is test string';
const testConstInt = 1234;
const testConstFloat = 1234.567;
''';
  late final userScript = UserScript(source: jsSource, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          supportZoom: false,
          transparentBackground: true,
          verticalScrollBarEnabled: false,
          cacheEnabled: false,
          // iOS에서 유튜브 웹뷰 안에서 재생하기 위한 옵션
          allowsInlineMediaPlayback: true,
        ),
        initialUserScripts: UnmodifiableListView([userScript]),
        onWebViewCreated: (controller) {
          // controller.addJavaScriptHandler(handlerName: handlerName, callback: callback)
          // controller.addJavaScriptHandler(handlerName: handlerName, callback: callback)
          // controller.addUserScript(userScript: UserScript(source: '', injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START));
          // controller.e
        },
        initialUrlRequest: URLRequest(url: WebUri('http://192.168.50.147:8080')),
      ),
    );
  }
}
