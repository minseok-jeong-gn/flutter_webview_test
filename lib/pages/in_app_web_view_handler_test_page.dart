import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v4.dart';

import '../enums/test_website.dart';
import '../widgets/my_text.dart';

const String _customScheme = 'app-bridge-file';

class InAppWebViewHandlerTestPage extends StatefulWidget {
  const InAppWebViewHandlerTestPage({super.key});

  @override
  State<InAppWebViewHandlerTestPage> createState() => _InAppWebViewHandlerTestPageState();
}

class _InAppWebViewHandlerTestPageState extends State<InAppWebViewHandlerTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JavaScript Handlers')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _InAppWebViewAllowFileUrlTest(
                url: TestWebsite.localDartShelfServerTest.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InAppWebViewHandlerWidget extends StatelessWidget {
  _InAppWebViewHandlerWidget({
    required this.url,
  });

  final String url;
  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
    allowsInlineMediaPlayback: true,
    allowFileAccess: false,
    allowFileAccessFromFileURLs: false,
    allowUniversalAccessFromFileURLs: false,
    javaScriptCanOpenWindowsAutomatically: true,
    javaScriptEnabled: true,
  );

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: settings,
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onWebViewCreated: (controller) async {
        await initJavascriptHandler(controller, context);
      },
    );
  }
}

class _InAppWebViewAllowFileUrlTest extends StatelessWidget {
  _InAppWebViewAllowFileUrlTest({
    required this.url,
  });

  final String url;

  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
    allowFileAccess: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    allowContentAccess: true,
    javaScriptCanOpenWindowsAutomatically: true,
    javaScriptEnabled: true,
    resourceCustomSchemes: [_customScheme],
  );

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: settings,
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onLoadResourceWithCustomScheme: (controller, request) async {
        if (request.url.scheme == _customScheme) {
          final filePath = request.url.toString().replaceFirst('$_customScheme:', '', 0);
          final file = File(filePath);
          final mimeType = lookupMimeType(filePath);
          final response = CustomSchemeResponse(
            data: await file.readAsBytes(),
            contentType: mimeType!,
          );
          return response;
        }
        return null;
      },
      onWebViewCreated: (controller) async {
        await initJavascriptHandler(controller, context);
      },
    );
  }
}

Future<void> initJavascriptHandler(
  InAppWebViewController controller,
  BuildContext context,
) async {
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
    handlerName: 'pickImageByDataUrl',
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
    handlerName: 'pickImageByCustomScheme',
    callback: (_) async {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) {
        return null;
      } else {
        final cachedDirectory = await getApplicationCacheDirectory();
        final fileExtension = image.path.split('.').last;
        final newImagePath = '${cachedDirectory.path}/${const UuidV4().generate()}.$fileExtension';
        await File(image.path).copy(newImagePath);
        final fileUrl = Uri(scheme: _customScheme, path: newImagePath);
        log(fileUrl.toString());
        return {
          'url': fileUrl.toString(),
        };
      }
    },
  );

  controller.addJavaScriptHandler(
    handlerName: 'pickImageByFileUrl',
    callback: (_) async {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) {
        return null;
      } else {
        final cachedDirectory = await getApplicationCacheDirectory();
        final fileExtension = image.path.split('.').last;
        final newImagePath = '${cachedDirectory.path}/${const UuidV4().generate()}.$fileExtension';
        await File(image.path).copy(newImagePath);
        final fileUrl = Uri(scheme: _customScheme, path: newImagePath);
        log(fileUrl.toString());
        return {
          'url': fileUrl.toString(),
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
}
