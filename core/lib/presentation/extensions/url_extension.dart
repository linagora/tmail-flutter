extension URLExtension on String {
  static final String prefixUrlHttps = 'https://';
  static final String prefixUrlHttp = 'http://';

  String formatURLValid() {
    if (startsWith(prefixUrlHttps)) {
      return this;
    } else if (startsWith(prefixUrlHttp)) {
      return replaceAll(prefixUrlHttp, prefixUrlHttps);
    } else {
      return '$prefixUrlHttps${this}';
    }
  }
}