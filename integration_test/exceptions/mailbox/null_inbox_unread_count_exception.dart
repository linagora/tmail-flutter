import 'package:core/domain/exceptions/app_base_exception.dart';

class NullInboxUnreadCountException extends AppBaseException {
  const NullInboxUnreadCountException([super.message]);

  @override
  String get exceptionName => 'NullInboxUnreadCountException';
}
