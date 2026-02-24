import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundSendingEmailHiveObject extends AppBaseException {
  NotFoundSendingEmailHiveObject([super.message]);

  @override
  String get exceptionName => 'NotFoundSendingEmailHiveObject';
}

class ExistSendingEmailHiveObject extends AppBaseException {
  ExistSendingEmailHiveObject([super.message]);

  @override
  String get exceptionName => 'ExistSendingEmailHiveObject';
}
