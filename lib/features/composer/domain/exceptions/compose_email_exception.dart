import 'package:core/domain/exceptions/app_base_exception.dart';

class SendingEmailCanceledException extends AppBaseException {
  SendingEmailCanceledException([super.message]);

  @override
  String get exceptionName => 'SendingEmailCanceledException';
}

class SavingEmailToDraftsCanceledException extends AppBaseException {
  SavingEmailToDraftsCanceledException([super.message]);

  @override
  String get exceptionName => 'SavingEmailToDraftsCanceledException';
}
