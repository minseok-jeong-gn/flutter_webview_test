import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../enums/test_website.dart';
import '../widgets/my_text.dart';
import 'in_app_web_view_handler_test_page.dart';
import 'webview_flutter_handler_test_page.dart';
import 'webview_scroll_test_page.dart';
import 'webview_performance_test_page.dart';

class TestListPage extends StatelessWidget {
  const TestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyText.extraLarge('테스트 목록'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebviewPerformanceTestPage(
                    testWebsite: TestWebsite.benchMarkTest,
                  ),
                ),
              );
            },
            title: MyText.large('성능 벤치 마크'),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebviewPerformanceTestPage(
                    testWebsite: TestWebsite.naverMap,
                  ),
                ),
              );
            },
            title: MyText.large('네이버 지도'),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebviewScrollTestPage(),
                ),
              );
            },
            title: MyText.large('웹뷰 스크롤'),
          ),
          ListTile(
            onTap: () async {
              await Permission.storage.request();
              await Permission.photos.request();
              await Permission.camera.request();

              if (!context.mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InAppWebViewHandlerTestPage(),
                ),
              );
            },
            title: MyText.large('인앱 웹뷰 핸들러'),
          ),
          ListTile(
            onTap: () async {
              await Permission.storage.request();
              await Permission.photos.request();
              await Permission.camera.request();

              if (!context.mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebviewFlutterHandlerTestPage(),
                ),
              );
            },
            title: MyText.large('웹뷰 플러터 핸들러'),
          ),
          ListTile(
            onTap: () {
              WebSocket.connect('ws://192.168.50.147:8082').then((ws) async {
                ws.listen((message) {
                  log('receive from websocket server: $message');
                });
                for (int i = 0; i < 10; ++i) {
                  ws.add('${DateTime.now()}');
                  await Future.delayed(const Duration(milliseconds: 500));
                }

                ws.close();
              });
            },
            title: MyText.large('웹소켓 테스트'),
          ),
        ],
      ),
    );
  }
}
