import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';

import 'calendar_event_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CalendarEventDataSource>(),
  MockSpec<HtmlDataSource>(),
])
void main() {
  final calendarEventNetworkDataSource = MockCalendarEventDataSource();
  final calendarEventRepository = CalendarEventRepositoryImpl(
    {DataSourceType.network: calendarEventNetworkDataSource},
    MockHtmlDataSource(),
  );
  final accountId = AccountId(Id('123'));
  final blobId = Id('blobId');
  const language = 'en';

  group('calendar event repository test:', () {
    final calendarEventAcceptResponseresponse = CalendarEventAcceptResponse(
      accountId,
      null,
      accepted: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventAcceptResponseresponse);

      final response = await calendarEventRepository.acceptEventInvitation(accountId, {blobId}, language);

      expect(response, calendarEventAcceptResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenThrow(NotAcceptableCalendarEventException());

      expect(
        () => calendarEventRepository.acceptEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotAcceptableCalendarEventException>()));
    });
  });

  group('calendar event maybe repository test:', () {
    final calendarEventMaybeResponse = CalendarEventMaybeResponse(
      accountId,
      null,
      maybe: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventMaybeResponse);

      final response = await calendarEventRepository.maybeEventInvitation(accountId, {blobId}, language);

      expect(response, calendarEventMaybeResponse);
    });

    test('should throw exception when data source throw exception', () {
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenThrow(NotMaybeableCalendarEventException());

      expect(
        () => calendarEventRepository.maybeEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotMaybeableCalendarEventException>()));
    });
  });

  group('calendar event reject repository test:', () {
    final calendarEventRejectResponseresponse = CalendarEventRejectResponse(
      accountId,
      null,
      rejected: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventRejectResponseresponse);

      final response = await calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language);

      expect(response, calendarEventRejectResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenThrow(NotRejectableCalendarEventException());

      expect(
        () => calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotRejectableCalendarEventException>()));
    });
  });
}
