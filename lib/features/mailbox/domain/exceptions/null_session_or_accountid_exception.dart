import 'package:core/domain/exceptions/app_base_exception.dart';

class NullSessionOrAccountIdException extends AppBaseException {
  const NullSessionOrAccountIdException(
      [super.message = 'session and accountId should not be null']);

  @override
  String get exceptionName => 'NullSessionOrAccountIdException';
}
