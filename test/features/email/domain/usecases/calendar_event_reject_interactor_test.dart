import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reject_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_reject_interactor.dart';

import 'calendar_event_accept_interactor_test.mocks.dart';

void main() {
  final calendarEventRepository = MockCalendarEventRepository();
  final rejectCalendarEventInteractor = RejectCalendarEventInteractor(calendarEventRepository);
  final accountId = AccountId(Id('123'));
  final blobId = Id('123321');

  group('calendar event reject interactor test:', () {
    test('should emit CalendarEventRejected when repo return data', () {
      // arrange
      final calendarEventRejectResponse = CalendarEventRejectResponse(
        accountId,
        null,
        rejected: [EventId(blobId.value)]);
      when(calendarEventRepository.rejectEventInvitation(any, any))
        .thenAnswer((_) async => calendarEventRejectResponse);

      // assert
      expect(
        rejectCalendarEventInteractor.execute(accountId, {blobId}),
        emitsInOrder([
          Right(CalendarEventRejecting()),
          Right(CalendarEventRejected(calendarEventRejectResponse))]));
    });

    test('should emit CalendarEventRejectFailure when repo throw exception', () {
      // arrange
      final exception = NotRejectableCalendarEventException();
      when(calendarEventRepository.rejectEventInvitation(any, any)).thenThrow(exception);

      // assert
      expect(
        rejectCalendarEventInteractor.execute(accountId, {blobId}),
        emitsInOrder([
          Right(CalendarEventRejecting()),
          Left(CalendarEventRejectFailure(exception: exception))]));
    });
  });
}