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
  final htmlDatasource = MockHtmlDataSource();
  final calendarEventDataSource = {
    DataSourceType.network: calendarEventNetworkDataSource};
  final calendarEventRepository = CalendarEventRepositoryImpl(
    calendarEventDataSource,
    htmlDatasource,
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
      // arrange
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventAcceptResponseresponse);

      // act
      final response = await calendarEventRepository.acceptEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventAcceptResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenThrow(NotAcceptableCalendarEventException());
      
      // assert
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
      // arrange
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventMaybeResponse);

      // act
      final response = await calendarEventRepository.maybeEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventMaybeResponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenThrow(NotMaybeableCalendarEventException());
      
      // assert
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
      // arrange
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventRejectResponseresponse);

      // act
      final response = await calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventRejectResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenThrow(NotRejectableCalendarEventException());
      
      // assert
      expect(
        () => calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotRejectableCalendarEventException>()));
    });
  });
}