import 'package:flutter/foundation.dart';

extension URLExtension on String {
  static final String prefixUrlHttps = 'https://';
  static final String prefixUrlHttp = 'http://';

  String formatURLValid() {
    if (startsWith(prefixUrlHttps)) {
      return this;
    } else if (startsWith(prefixUrlHttp)) {
      return kReleaseMode ? replaceAll(prefixUrlHttp, prefixUrlHttps) : this;
    } else {
      return '$prefixUrlHttps${this}';
    }
  }
}