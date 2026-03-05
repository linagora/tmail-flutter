import 'package:core/domain/exceptions/app_base_exception.dart';

class CannotCreatePublicAssetException extends AppBaseException {
  const CannotCreatePublicAssetException([super.message]);

  @override
  String get exceptionName => 'CannotCreatePublicAssetException';
}

class PublicAssetQuotaExceededException extends AppBaseException {
  const PublicAssetQuotaExceededException([super.message]);

  @override
  String get exceptionName => 'PublicAssetQuotaExceededException';
}

class CannotDestroyPublicAssetException extends AppBaseException {
  const CannotDestroyPublicAssetException([super.message]);

  @override
  String get exceptionName => 'CannotDestroyPublicAssetException';
}

class CannotUpdatePublicAssetException extends AppBaseException {
  const CannotUpdatePublicAssetException([super.message]);

  @override
  String get exceptionName => 'CannotUpdatePublicAssetException';
}
