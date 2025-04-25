enum TestWebsite {
  benchMarkTest,
  naverMap,
  localDartShelfServerTest,
  localDartShelfServerTest2,
  ;

  String get url => switch (this) {
        benchMarkTest => 'https://browserbench.org/',
        naverMap => 'https://map.naver.com/',
        localDartShelfServerTest => 'http://192.168.50.147:8081/flutter-inapp-webview-test.html',
        localDartShelfServerTest2 => 'http://192.168.50.147:8081/webview-flutter-test.html',
      };
}
