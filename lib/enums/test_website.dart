enum TestWebsite {
  benchMarkTest,
  naverMap,
  ;

  String get url => switch (this) {
        benchMarkTest => 'https://browserbench.org/',
        naverMap => 'https://map.naver.com/',
      };
}
