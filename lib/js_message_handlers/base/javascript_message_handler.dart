import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import 'javascript_message_handler_result.dart';

abstract interface class JavascriptMessageHandler {
  String get messageName;
  FutureOr<JavascriptMessageHandlerResult> handle(Map<String, Object?> params, WebViewController controller);
}
