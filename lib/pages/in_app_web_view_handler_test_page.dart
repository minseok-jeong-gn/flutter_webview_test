import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../widgets/my_text.dart';

WebViewEnvironment? webViewEnvironment;

class InAppWebViewHandlerTestPage extends StatefulWidget {
  const InAppWebViewHandlerTestPage({super.key});

  @override
  State<InAppWebViewHandlerTestPage> createState() => _InAppWebViewHandlerTestPageState();
}

class _InAppWebViewHandlerTestPageState extends State<InAppWebViewHandlerTestPage> {
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JavaScript Handlers')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _InAppWebViewHandlerWidget(
                settings: settings,
                url: 'http://192.168.50.147:8080/index.html',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InAppWebViewHandlerWidget extends StatelessWidget {
  const _InAppWebViewHandlerWidget({
    required this.url,
    required this.settings,
  });

  final String url;
  final InAppWebViewSettings settings;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
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

        controller.addJavaScriptHandler(
          handlerName: 'getGalleryImage',
          callback: (_) async {
            final image = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image == null) {
              return null;
            } else {
              final imageBytes = await image.readAsBytes();
              final mimeType = lookupMimeType(image.path);
              final uriData = UriData.fromBytes(imageBytes, mimeType: mimeType!);
              log(uriData.uri.toString());
              return {
                'url': uriData.uri.toString(),
              };
            }
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'pushPage',
          callback: (args) async {
            final url = args.first as String;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: MyText.large('Pushed Page'),
                  ),
                  body: _InAppWebViewHandlerWidget(
                    settings: settings,
                    url: url,
                  ),
                ),
              ),
            );
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'popPage',
          callback: (_) async {
            Navigator.pop(context);
            return null;
          },
        );

        // const localTestWebsite = 'http://192.168.50.147:8080/index.html';
        controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      },
      onConsoleMessage: (controller, consoleMessage) {
        log(consoleMessage.toString());
      },
    );
  }
}
