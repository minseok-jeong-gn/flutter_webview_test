import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_test/pages/long_duration_transition_page_route.dart';
import 'package:webview_test/widgets/my_text.dart';
import 'package:webview_test/utils/ui_helper.dart';

const flutterVersion = 'v3.29.3';

enum PlatformViewImplementationType {
  hc, //hybrid composition
  tlhc, //texture layer hybrid composition
}

enum TestWebsite {
  benchMarkTest,
  naverMap,
  ;

  String get url => switch (this) {
        benchMarkTest => 'https://browserbench.org/',
        naverMap => 'https://map.naver.com/',
      };
}

class WebviewPerformanceTestPage extends StatefulWidget {
  const WebviewPerformanceTestPage({
    super.key,
    required this.testWebsite,
  });

  final TestWebsite testWebsite;

  @override
  State<WebviewPerformanceTestPage> createState() => _WebviewPerformanceTestPageState();
}

class _WebviewPerformanceTestPageState extends State<WebviewPerformanceTestPage> {
  @override
  Widget build(BuildContext context) {
    final String url = widget.testWebsite.url;
    return Scaffold(
      appBar: AppBar(
        title: MyText.extraLarge(widget.testWebsite.name),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildFlutterInAppWebViewCardWidget(context, url),
            const Gap(16.0),
            _buildWebViewFlutterCardWidget(context, url),
          ],
        ),
      ),
    );
  }

  Card _buildWebViewFlutterCardWidget(
    final BuildContext context,
    final String url,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'webview_flutter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(24.0),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      LongDurationTransitionPageRoute(
                        builder: (context) => _PeftTestWebViewFlutter(
                          platformViewImplementationType: PlatformViewImplementationType.hc,
                          url: url,
                        ),
                      ),
                    );
                  },
                  child: Text(PlatformViewImplementationType.hc.name),
                ),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        LongDurationTransitionPageRoute(
                          builder: (context) => _PeftTestWebViewFlutter(
                            platformViewImplementationType: PlatformViewImplementationType.tlhc,
                            url: url,
                          ),
                        ),
                      );
                    },
                    child: Text(PlatformViewImplementationType.tlhc.name),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Card _buildFlutterInAppWebViewCardWidget(
    final BuildContext context,
    final String url,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'flutter_inappwebview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(24.0),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      LongDurationTransitionPageRoute(
                        builder: (context) => _PerfTestFlutterInAppWebView(
                          platformViewImplementationType: PlatformViewImplementationType.hc,
                          url: url,
                        ),
                      ),
                    );
                  },
                  child: Text(PlatformViewImplementationType.hc.name),
                ),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        LongDurationTransitionPageRoute(
                          builder: (context) => _PerfTestFlutterInAppWebView(
                            platformViewImplementationType: PlatformViewImplementationType.tlhc,
                            url: url,
                          ),
                        ),
                      );
                    },
                    child: Text(PlatformViewImplementationType.tlhc.name),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PerfTestFlutterInAppWebView extends StatelessWidget {
  const _PerfTestFlutterInAppWebView({
    required this.platformViewImplementationType,
    required this.url,
  });

  final PlatformViewImplementationType platformViewImplementationType;
  final String url;

  @override
  Widget build(BuildContext context) {
    final bool useHybridComposition = switch (platformViewImplementationType) {
      PlatformViewImplementationType.hc => true,
      PlatformViewImplementationType.tlhc => false,
    };

    final String title = () {
      final stringBuffer = StringBuffer();
      stringBuffer.write('flutter_inappwebview');
      if (Platform.isAndroid) {
        stringBuffer.write(' (${platformViewImplementationType.name})');
      } else {
        stringBuffer.write(' ');
      }
      stringBuffer.write(flutterVersion);
      return stringBuffer.toString();
    }();

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(title)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                LongDurationTransitionPageRoute(
                  builder: (context) => _PerfTestFlutterInAppWebView(
                    platformViewImplementationType: platformViewImplementationType,
                    url: url,
                  ),
                ),
              );
            },
            child: const Text('Push'),
          ),
          TextButton(
            onPressed: () {
              UiHelper.showBottomSheet(context);
            },
            child: const Text('BS'),
          ),
        ],
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(useHybridComposition: useHybridComposition),
        initialUrlRequest: URLRequest(
          url: WebUri(url),
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
  const _PeftTestWebViewFlutter({
    required this.platformViewImplementationType,
    required this.url,
  });

  final PlatformViewImplementationType platformViewImplementationType;
  final String url;

  @override
  State<_PeftTestWebViewFlutter> createState() => _PeftTestWebViewFlutterState();
}

class _PeftTestWebViewFlutterState extends State<_PeftTestWebViewFlutter> {
  WebViewController? _controller;
  PlatformWebViewController? _androidWebViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _androidWebViewController = AndroidWebViewController(AndroidWebViewControllerCreationParams())
        ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)))
        ..setOnConsoleMessage((javascriptConsoleMessage) {
          log(javascriptConsoleMessage.toString());
        })
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
    } else {
      _controller = WebViewController()
        ..loadRequest(Uri.parse(widget.url))
        ..setOnConsoleMessage((javascriptConsoleMessage) {
          log(javascriptConsoleMessage.toString());
        })
        ..setJavaScriptMode(JavaScriptMode.unrestricted);

      _controller?.getUserAgent().then((v) {
        log('webview_flutter user-agnet info:\n$v');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = () {
      final stringBuffer = StringBuffer();
      stringBuffer.write('webview_flutter');
      if (Platform.isAndroid) {
        stringBuffer.write(' (${widget.platformViewImplementationType.name})');
      } else {
        stringBuffer.write(' ');
      }
      stringBuffer.write(flutterVersion);
      return stringBuffer.toString();
    }();

    late Widget webViewWidget;
    if (Platform.isAndroid) {
      switch (widget.platformViewImplementationType) {
        case PlatformViewImplementationType.hc:
          webViewWidget = WebViewWidget.fromPlatformCreationParams(
              params: AndroidWebViewWidgetCreationParams(
            controller: _androidWebViewController!,
            displayWithHybridComposition: true,
          ));
        case PlatformViewImplementationType.tlhc:
          webViewWidget = WebViewWidget.fromPlatformCreationParams(
              params: AndroidWebViewWidgetCreationParams(
            controller: _androidWebViewController!,
            displayWithHybridComposition: false,
          ));
      }
    } else {
      webViewWidget = WebViewWidget(controller: _controller!);
    }
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(title)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                LongDurationTransitionPageRoute(
                  builder: (context) => _PeftTestWebViewFlutter(
                    platformViewImplementationType: widget.platformViewImplementationType,
                    url: widget.url,
                  ),
                ),
              );
            },
            child: const Text('Push'),
          ),
          TextButton(
            onPressed: () {
              UiHelper.showBottomSheet(context);
            },
            child: const Text('BS'),
          ),
        ],
      ),
      body: webViewWidget,
    );
  }
}
