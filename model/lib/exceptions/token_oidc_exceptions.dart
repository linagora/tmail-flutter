import 'package:core/domain/exceptions/app_base_exception.dart';

class AccessTokenIsNullException extends AppBaseException {
  AccessTokenIsNullException([super.message]);

  @override
  String get exceptionName => 'AccessTokenIsNullException';
}

class RefreshTokenIsNullException extends AppBaseException {
  RefreshTokenIsNullException([super.message]);

  @override
  String get exceptionName => 'RefreshTokenIsNullException';
}

class TokenIdIsNullException extends AppBaseException {
  TokenIdIsNullException([super.message]);

  @override
  String get exceptionName => 'TokenIdIsNullException';
}

class ExpiresTimeIsNullException extends AppBaseException {
  ExpiresTimeIsNullException([super.message]);

  @override
  String get exceptionName => 'ExpiresTimeIsNullException';
}
