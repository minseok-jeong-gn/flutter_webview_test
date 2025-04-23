import 'platform_view_implementation_type.dart';

enum WebViewTestCase {
  webViewFlutterWithHybridComposition,
  webViewFlutterWithTextureLayerHybridComposition,
  flutterInAppWebViewWithHybridComposition,
  flutterInAppWebViewWithTextureLayerHybridComposition,
  ;

  PlatformViewImplementationType get type => switch (this) {
        WebViewTestCase.webViewFlutterWithHybridComposition => PlatformViewImplementationType.hc,
        WebViewTestCase.webViewFlutterWithTextureLayerHybridComposition => PlatformViewImplementationType.tlhc,
        WebViewTestCase.flutterInAppWebViewWithHybridComposition => PlatformViewImplementationType.hc,
        WebViewTestCase.flutterInAppWebViewWithTextureLayerHybridComposition => PlatformViewImplementationType.tlhc,
      };

  String get shortName => switch (this) {
        WebViewTestCase.webViewFlutterWithHybridComposition => 'webview_flutter(${type.name.toUpperCase()})',
        WebViewTestCase.webViewFlutterWithTextureLayerHybridComposition => 'webview_flutter(${type.name.toUpperCase()})',
        WebViewTestCase.flutterInAppWebViewWithHybridComposition => 'flutter_inappwebview(${type.name.toUpperCase()})',
        WebViewTestCase.flutterInAppWebViewWithTextureLayerHybridComposition => 'flutter_inappwebview(${type.name.toUpperCase()})',
      };
}
