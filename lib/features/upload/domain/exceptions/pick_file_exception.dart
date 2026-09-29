import 'package:core/domain/exceptions/app_base_exception.dart';

class PickFileCanceledException extends AppBaseException {
  const PickFileCanceledException([super.message]);

  @override
  String get exceptionName => 'PickFileCanceledException';
}

/// The picker couldn't report a size, sync or async. Surfaced instead of
/// guessing 0, which would let an oversized file skip the size-limit check.
class FileSizeUnavailableException extends AppBaseException {
  const FileSizeUnavailableException([super.message]);

  @override
  String get exceptionName => 'FileSizeUnavailableException';
}
