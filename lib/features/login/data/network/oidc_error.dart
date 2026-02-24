import 'package:core/domain/exceptions/app_base_exception.dart';

class CanNotFoundOIDCAuthority extends AppBaseException {
  CanNotFoundOIDCAuthority([super.message]);

  @override
  String get exceptionName => 'CanNotFoundOIDCAuthority';
}

class CanNotFoundOIDCLinks extends AppBaseException {
  CanNotFoundOIDCLinks([super.message]);

  @override
  String get exceptionName => 'CanNotFoundOIDCLinks';
}

class CanNotFindToken extends AppBaseException {
  CanNotFindToken([super.message]);

  @override
  String get exceptionName => 'CanNotFindToken';
}

class CanRetryOIDCException extends AppBaseException {
  CanRetryOIDCException([super.message]);

  @override
  String get exceptionName => 'CanRetryOIDCException';
}

class NotFoundUserInfoEndpointException extends AppBaseException {
  NotFoundUserInfoEndpointException([super.message]);

  @override
  String get exceptionName => 'NotFoundUserInfoEndpointException';
}
