
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/network/calendar_event_api.dart';
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
  Future<CalendarEventAcceptResponse> acceptEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language) {
    return Future.sync(() async {
      return await _calendarEventAPI.acceptEventInvitation(accountId, blobIds, language);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<CalendarEventMaybeResponse> maybeEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language) {
    return Future.sync(() async {
      return await _calendarEventAPI.maybeEventInvitation(accountId, blobIds, language);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<CalendarEventRejectResponse> rejectEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language) {
    return Future.sync(() async {
      return await _calendarEventAPI.rejectEventInvitation(accountId, blobIds, language);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<CalendarEventAcceptResponse> acceptCounterEvent(
    AccountId accountId,
    Set<Id> blobIds,
  ) {
    return Future.sync(() async {
      return await _calendarEventAPI.acceptCounterEvent(accountId, blobIds);
    }).catchError(_exceptionThrower.throwException);
  }
}