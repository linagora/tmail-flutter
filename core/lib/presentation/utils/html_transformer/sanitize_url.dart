import 'package:get/get.dart';

class SanitizeUrl {

  final bool defaultToHttps;

  SanitizeUrl({this.defaultToHttps = true});

  final _protocolIdentifierRegex = RegExp(
    r'^(https?://)',
    caseSensitive: false,
  );

  String process(String inputText) {
    var originalUrl = inputText;

    originalUrl = Uri.decodeFull(originalUrl);

    if (GetUtils.isURL(originalUrl)) {
      if (!originalUrl.startsWith(_protocolIdentifierRegex)) {
        originalUrl = (defaultToHttps ? "https://" : "http://") + originalUrl;
      }
    } else {
      originalUrl = '';
    }
    return originalUrl;
  }
}