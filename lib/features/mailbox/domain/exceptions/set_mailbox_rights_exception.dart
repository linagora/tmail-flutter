import 'package:core/domain/exceptions/app_base_exception.dart';

class SetMailboxRightsException extends AppBaseException {
  SetMailboxRightsException(
      [super.message = 'Failed to update mailbox rights.']);

  @override
  String get exceptionName => 'SetMailboxRightsException';
}
