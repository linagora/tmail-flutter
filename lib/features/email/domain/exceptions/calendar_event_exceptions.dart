
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class NotFoundCalendarEventException implements Exception {}

class NotParsableCalendarEventException implements Exception {}

class NotAcceptableCalendarEventException implements Exception {}

class NotMaybeableCalendarEventException implements Exception {}

class NotRejectableCalendarEventException implements Exception {}

class CannotReplyCalendarEventException implements Exception {
  final Map<Id, SetError>? mapErrors;

  CannotReplyCalendarEventException({this.mapErrors});
}