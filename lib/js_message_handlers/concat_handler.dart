import 'dart:async';

import 'base/javascript_message_handler.dart';
import 'base/javascript_message_handler_result.dart';

class ConcatHandler implements JavascriptMessageHandler {
  @override
  String get messageName => 'concat';

  @override
  FutureOr<JavascriptMessageHandlerResult> call(
    Map<String, Object?> params,
    _,
  ) {
    final concatResult = params.values.cast<String>().join();
    return JavascriptMessageHandlerResult(resultOk: true, data: {'data': concatResult});
  }
}
