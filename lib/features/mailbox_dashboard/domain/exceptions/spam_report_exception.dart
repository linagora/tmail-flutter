import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundLastTimeDismissedSpamReportException extends AppBaseException {
  NotFoundLastTimeDismissedSpamReportException([super.message]);

  @override
  String get exceptionName => 'NotFoundLastTimeDismissedSpamReportException';
}

class NotFoundSpamMailboxCachedException extends AppBaseException {
  NotFoundSpamMailboxCachedException([super.message]);

  @override
  String get exceptionName => 'NotFoundSpamMailboxCachedException';
}

class NotFoundSpamMailboxException extends AppBaseException {
  NotFoundSpamMailboxException([super.message]);

  @override
  String get exceptionName => 'NotFoundSpamMailboxException';
}
