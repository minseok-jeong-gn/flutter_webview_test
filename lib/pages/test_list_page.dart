import 'package:flutter/material.dart';

import '../widgets/my_text.dart';
import 'in_app_web_view_handler_test_page.dart';
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InAppWebViewHandlerTestPage(),
                ),
              );
            },
            title: MyText.large('인앱 웹뷰 핸들러'),
          ),
        ],
      ),
    );
  }
}
