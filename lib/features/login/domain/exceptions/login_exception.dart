
import 'package:flutter/services.dart';

class NotFoundDataResourceRecordException implements Exception {}

class NotFoundUrlException implements Exception {}

class InvalidOIDCResponseException implements Exception {}

class NoSuitableBrowserForOIDCException implements Exception {

  static const noBrowserAvailableCode = 'no_browser_available';

  static bool verifyException(dynamic exception) {
    if (exception is PlatformException) {
      if (exception.code == noBrowserAvailableCode) {
        return true;
      }
    }
    return false;
  }
}

