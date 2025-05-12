import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'base/javascript_message_handler.dart';
import 'base/javascript_message_handler_result.dart';

class CheckPermissionHandler implements JavascriptMessageHandler {
  @override
  String get messageName => 'checkPermission';

  @override
  FutureOr<JavascriptMessageHandlerResult> call(
    Map<String, Object?> params,
    WebViewController controller,
  ) async {
    final permissionList = List<String>.from(params['permissions'] as List);
    final result = <Map>[];
    for (final permission in permissionList) {
      switch (permission) {
        case 'camera':
          final permissionStatus = await Permission.camera.status;
          result.add({
            permission: permission,
            'status': permissionStatus.name,
          });
          break;
        // TODO: below cases
        //  "camera", "gallery", "notification", "location" permissions
        default:
          result.add({
            permission: permission,
            'status': 'denied',
          });
          break;
      }
    }

    return JavascriptMessageHandlerResult(resultOk: true, data: {'data': result});
  }
}
