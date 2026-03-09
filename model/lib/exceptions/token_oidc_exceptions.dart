import 'package:core/domain/exceptions/app_base_exception.dart';

class AccessTokenIsNullException extends AppBaseException {
  const AccessTokenIsNullException([super.message]);

  @override
  String get exceptionName => 'AccessTokenIsNullException';
}

class RefreshTokenIsNullException extends AppBaseException {
  const RefreshTokenIsNullException([super.message]);

  @override
  String get exceptionName => 'RefreshTokenIsNullException';
}

class TokenIdIsNullException extends AppBaseException {
  const TokenIdIsNullException([super.message]);

  @override
  String get exceptionName => 'TokenIdIsNullException';
}

class ExpiresTimeIsNullException extends AppBaseException {
  const ExpiresTimeIsNullException([super.message]);

  @override
  String get exceptionName => 'ExpiresTimeIsNullException';
}
