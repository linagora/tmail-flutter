import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundDataWithThisKeyException extends AppBaseException {
  const NotFoundDataWithThisKeyException([super.message]);

  @override
  String get exceptionName => 'NotFoundDataWithThisKeyException';
}

class NotFoundSentryConfigurationException extends AppBaseException {
  const NotFoundSentryConfigurationException([super.message]);

  @override
  String get exceptionName => 'NotFoundSentryConfigurationException';
}