import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundCalendarEventException extends AppBaseException {
  NotFoundCalendarEventException([super.message]);

  @override
  String get exceptionName => 'NotFoundCalendarEventException';
}

class NotParsableCalendarEventException extends AppBaseException {
  NotParsableCalendarEventException([super.message]);

  @override
  String get exceptionName => 'NotParsableCalendarEventException';
}

class NotAcceptableCalendarEventException extends AppBaseException {
  NotAcceptableCalendarEventException([super.message]);

  @override
  String get exceptionName => 'NotAcceptableCalendarEventException';
}

class NotMaybeableCalendarEventException extends AppBaseException {
  NotMaybeableCalendarEventException([super.message]);

  @override
  String get exceptionName => 'NotMaybeableCalendarEventException';
}

class NotRejectableCalendarEventException extends AppBaseException {
  NotRejectableCalendarEventException([super.message]);

  @override
  String get exceptionName => 'NotRejectableCalendarEventException';
}

class CannotReplyCalendarEventException extends AppBaseException {
  final Map<Id, SetError>? mapErrors;

  CannotReplyCalendarEventException({this.mapErrors})
      : super(mapErrors != null ? 'Errors: $mapErrors' : null);

  @override
  String get exceptionName => 'CannotReplyCalendarEventException';
}
