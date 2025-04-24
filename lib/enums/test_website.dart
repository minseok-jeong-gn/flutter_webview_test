enum TestWebsite {
  benchMarkTest,
  naverMap,
  localDartShelfServerTest,
  ;

  String get url => switch (this) {
        benchMarkTest => 'https://browserbench.org/',
        naverMap => 'https://map.naver.com/',
        localDartShelfServerTest => 'http://192.168.50.147:8081/index.html',
      };
}
