import 'dart:async';

import 'javascript_message_handler.dart';
import 'javascript_message_handler_result.dart';

class ConcatHandler implements JavascriptMessageHandler {
  @override
  String get messageName => 'concat';

  @override
  FutureOr<JavascriptMessageHandlerResult> handle(
    Map<String, Object?> params,
    _,
  ) {
    final concatResult = params.values.cast<String>().join();
    return JavascriptMessageHandlerResult(resultOk: true, data: {'data': concatResult});
  }
}
