import 'package:core/domain/exceptions/app_base_exception.dart';

class SavingEmailToDraftsCanceledException extends AppBaseException {
  SavingEmailToDraftsCanceledException([super.message]);

  @override
  String get exceptionName => 'SavingEmailToDraftsCanceledException';
}
