import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'javascript_message_handler.dart';
import 'javascript_message_handler_result.dart';

class GetDeviceInfoHandler implements JavascriptMessageHandler {
  @override
  String get messageName => 'getDeviceInfo';

  @override
  FutureOr<JavascriptMessageHandlerResult> handle(
    Map<String, Object?> params,
    _,
  ) async {
    late final BaseDeviceInfo deviceInfo;
    if (Platform.isAndroid) {
      deviceInfo = await DeviceInfoPlugin().androidInfo;
    } else {
      deviceInfo = await DeviceInfoPlugin().iosInfo;
    }

    return JavascriptMessageHandlerResult(
      resultOk: true,
      data: deviceInfo.data,
      errorMessage: null,
    );
  }
}
