
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/network/calendar_event_api.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CalendarEventDataSourceImpl extends CalendarEventDataSource {

  final CalendarEventAPI _calendarEventAPI;
  final ExceptionThrower _exceptionThrower;

  CalendarEventDataSourceImpl(this._calendarEventAPI, this._exceptionThrower);

  @override
  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) {
    return Future.sync(() async {
      return await _calendarEventAPI.parse(accountId, blobIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<EventAction>> getListEventAction(String emailContents) {
    throw UnimplementedError();
  }
  
  @override
  Future<CalendarEventAcceptResponse> acceptEventInvitation(AccountId accountId, Set<Id> blobIds) {
    return Future.sync(() async {
      return await _calendarEventAPI.acceptEventInvitation(accountId, blobIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<CalendarEventMaybeResponse> maybeEventInvitation(AccountId accountId, Set<Id> blobIds) {
    return Future.sync(() async {
      return await _calendarEventAPI.maybe(accountId, blobIds);
    }).catchError(_exceptionThrower.throwException);
  }
}