import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/get_calendar_event_attendance_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/get_calendar_event_attendance_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

class CalendarEventAPI {

  final HttpClient _httpClient;

  CalendarEventAPI(this._httpClient);

  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    // Parse
    final calendarEventParseMethod = CalendarEventParseMethod(accountId, blobIds);
    final calendarEventParseInvocation = requestBuilder.invocation(calendarEventParseMethod);

    // Free/Busy query
    final calendarEventAttendanceGetMethod = GetCalendarEventAttendanceMethod(
      accountId,
      blobIds.toList(),
    );
    final calendarEventAttendanceGetInvocation = requestBuilder.invocation(
      calendarEventAttendanceGetMethod,
    );

    final response = await (requestBuilder
        ..usings(calendarEventParseMethod.requiredCapabilities))
      .build()
      .execute();

    final calendarEventParseResponse = response.parse<CalendarEventParseResponse>(
      calendarEventParseInvocation.methodCallId,
      CalendarEventParseResponse.deserialize);
    final calendarEventAttendanceGetResponse = _parseCalendarEventAttendance(
      response,
      calendarEventAttendanceGetInvocation.methodCallId,
    );
    final calendarBlobIdStatusMap = Map.fromEntries(
      (calendarEventAttendanceGetResponse?.list ?? []).map(
        (calendarEventAttendance) => MapEntry(
          calendarEventAttendance.blobId,
          calendarEventAttendance.isFree,
        ),
      ),
    );

    if (calendarEventParseResponse?.parsed?.isNotEmpty == true) {
      return calendarEventParseResponse!.parsed!.entries
        .map((entry) => BlobCalendarEvent(
          blobId: entry.key,
          isFree: calendarBlobIdStatusMap[entry.key] ?? true,
          calendarEventList: entry.value))
        .toList();
    } else if (calendarEventParseResponse?.notParsable?.isNotEmpty == true) {
      throw NotParsableCalendarEventException();
    } else if (calendarEventParseResponse?.notFound?.isNotEmpty == true) {
      throw NotFoundCalendarEventException();
    } else {
      throw NotParsableCalendarEventException();
    }
  }

  GetCalendarEventAttendanceResponse? _parseCalendarEventAttendance(
    ResponseObject response,
    MethodCallId methodCallId,
  ) {
    try {
      return response.parse<GetCalendarEventAttendanceResponse>(
        methodCallId,
        GetCalendarEventAttendanceResponse.deserialize);
    } catch (e) {
      logError('CalendarEventAPI.parse free/busy query error: $e');
      return null;
    }
  }

  Future<CalendarEventAcceptResponse> acceptEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventAcceptMethod = CalendarEventAcceptMethod(
      accountId,
      blobIds: blobIds.toList());
    if (language != null) {
      calendarEventAcceptMethod.addLanguage(language);
    }
    final calendarEventAcceptInvocation = requestBuilder.invocation(calendarEventAcceptMethod);
    final response = await (requestBuilder..usings(calendarEventAcceptMethod.requiredCapabilities))
      .build()
      .execute();

    final calendarEventAcceptResponse = response.parse<CalendarEventAcceptResponse>(
      calendarEventAcceptInvocation.methodCallId,
      CalendarEventAcceptResponse.deserialize);

    if (calendarEventAcceptResponse == null) {
      throw NotAcceptableCalendarEventException();
    }

    if (calendarEventAcceptResponse.accepted?.isNotEmpty == true) {
      return calendarEventAcceptResponse;
    } else {
      throw CannotReplyCalendarEventException(mapErrors: calendarEventAcceptResponse.notAccepted);
    }
  }

  Future<CalendarEventMaybeResponse> maybeEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventMaybeMethod = CalendarEventMaybeMethod(
      accountId,
      blobIds: blobIds.toList());
    if (language != null) {
      calendarEventMaybeMethod.addLanguage(language);
    }
    final calendarEventMaybeInvocation = requestBuilder.invocation(calendarEventMaybeMethod);
    final response = await (requestBuilder..usings(calendarEventMaybeMethod.requiredCapabilities))
      .build()
      .execute();

    final calendarEventMaybeResponse = response.parse<CalendarEventMaybeResponse>(
      calendarEventMaybeInvocation.methodCallId,
      CalendarEventMaybeResponse.deserialize);

    if (calendarEventMaybeResponse == null) {
      throw NotMaybeableCalendarEventException();
    }

    if (calendarEventMaybeResponse.maybe?.isNotEmpty == true) {
      return calendarEventMaybeResponse;
    } else {
      throw CannotReplyCalendarEventException(mapErrors: calendarEventMaybeResponse.notMaybe);
    }
  }

  Future<CalendarEventRejectResponse> rejectEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventRejectMethod = CalendarEventRejectMethod(
      accountId,
      blobIds: blobIds.toList());
    if (language != null) {
      calendarEventRejectMethod.addLanguage(language);
    }
    final calendarEventRejectInvocation = requestBuilder.invocation(calendarEventRejectMethod);
    final response = await (requestBuilder..usings(calendarEventRejectMethod.requiredCapabilities))
      .build()
      .execute();

    final calendarEventRejectResponse = response.parse<CalendarEventRejectResponse>(
      calendarEventRejectInvocation.methodCallId,
      CalendarEventRejectResponse.deserialize);

    if (calendarEventRejectResponse == null) {
      throw NotRejectableCalendarEventException();
    }

    if (calendarEventRejectResponse.rejected?.isNotEmpty == true) {
      return calendarEventRejectResponse;
    } else {
      throw CannotReplyCalendarEventException(mapErrors: calendarEventRejectResponse.notRejected);
    }
  }
}