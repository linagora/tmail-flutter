import 'package:core/domain/exceptions/app_base_exception.dart';

abstract class CacheException extends AppBaseException {
  const CacheException([super.message]);
}

class UnknownCacheError extends CacheException {
  const UnknownCacheError([super.message]);

  @override
  String get exceptionName => 'UnknownCacheError';
}
