import 'package:flutter/services.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundDataResourceRecordException extends AppBaseException {
  NotFoundDataResourceRecordException([super.message]);

  @override
  String get exceptionName => 'NotFoundDataResourceRecordException';
}

class NotFoundUrlException extends AppBaseException {
  NotFoundUrlException([super.message]);

  @override
  String get exceptionName => 'NotFoundUrlException';
}

class InvalidOIDCResponseException extends AppBaseException {
  InvalidOIDCResponseException([super.message]);

  @override
  String get exceptionName => 'InvalidOIDCResponseException';
}

class NoSuitableBrowserForOIDCException extends AppBaseException {
  static const noBrowserAvailableCode = 'no_browser_available';

  NoSuitableBrowserForOIDCException([super.message]);

  @override
  String get exceptionName => 'NoSuitableBrowserForOIDCException';

  static bool verifyException(dynamic exception) {
    if (exception is PlatformException) {
      if (exception.code == noBrowserAvailableCode) {
        return true;
      }
    }
    return false;
  }
}

class NotFoundCompanyServerLoginInfoException extends AppBaseException {
  NotFoundCompanyServerLoginInfoException([super.message]);

  @override
  String get exceptionName => 'NotFoundCompanyServerLoginInfoException';
}
