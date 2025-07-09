import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';

class SanitizeUrl {

  final bool defaultToHttps;

  SanitizeUrl({this.defaultToHttps = true});

  final _protocolIdentifierRegex = RegExp(
    r'^(https?://)',
    caseSensitive: false,
  );

  String process(String inputText) {
    try {
      var originalUrl = Uri.decodeFull(inputText);
      if (GetUtils.isURL(originalUrl)) {
        originalUrl = !originalUrl.startsWith(_protocolIdentifierRegex)
          ? (defaultToHttps ? "https://" : "http://") + originalUrl
          : originalUrl;
      } else {
        originalUrl = '';
      }
      return originalUrl;
    } catch (e) {
      logError('SanitizeUrl::process:Exception = $e');
      return inputText;
    }
  }
}