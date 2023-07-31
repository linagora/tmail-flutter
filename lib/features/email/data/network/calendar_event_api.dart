import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/parse/calendar_event_parse_response.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';

class CalendarEventAPI {

  final HttpClient _httpClient;

  CalendarEventAPI(this._httpClient);

  Future<List<CalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) async {
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
      return calendarEventParseResponse!.parsed!.values.toList();
    } else if (calendarEventParseResponse?.notParsable?.isNotEmpty == true) {
      throw NotParsableCalendarEventException();
    } else if (calendarEventParseResponse?.notFound?.isNotEmpty == true) {
      throw NotFoundCalendarEventException();
    } else {
      throw NotParsableCalendarEventException();
    }
  }
}