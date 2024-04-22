import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

class CalendarEventAPI {

  final HttpClient _httpClient;

  CalendarEventAPI(this._httpClient);

  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventParseMethod = CalendarEventParseMethod(accountId, blobIds);
    final calendarEventParseInvocation = requestBuilder.invocation(calendarEventParseMethod);
    final response = await (requestBuilder
        ..usings(calendarEventParseMethod.requiredCapabilities))
      .build()
      .execute();

    final calendarEventParseResponse = response.parse<CalendarEventParseResponse>(
      calendarEventParseInvocation.methodCallId,
      CalendarEventParseResponse.deserialize);

    if (calendarEventParseResponse?.parsed?.isNotEmpty == true) {
      return calendarEventParseResponse!.parsed!.entries
        .map((entry) => BlobCalendarEvent(
          blobId: entry.key,
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

  Future<CalendarEventAcceptResponse> acceptEventInvitation(AccountId accountId, Set<Id> blobIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventAcceptMethod = CalendarEventAcceptMethod(
      accountId,
      blobIds: blobIds.toList());
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

    return calendarEventAcceptResponse;
  }

  Future<CalendarEventMaybeResponse> maybe(AccountId accountId, Set<Id> blobIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final calendarEventMaybeMethod = CalendarEventMaybeMethod(
      accountId,
      blobIds: blobIds.toList());
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

    return calendarEventMaybeResponse;
  }
}