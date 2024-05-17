import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_maybe_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/maybe_calendar_event_interactor.dart';

import 'calendar_event_accept_interactor_test.mocks.dart';

void main() {
  final calendarEventRepository = MockCalendarEventRepository();
  final maybeCalendarEventInteractor = MaybeCalendarEventInteractor(calendarEventRepository);
  final accountId = AccountId(Id('123'));
  final blobId = Id('123321');
  final emailId = EmailId(Id('abcde'));

  group('calendar event maybe interactor should emit expected states', () {
    test('when repo return data', () {
      // arrange
      final calendarEventMaybeResponse = CalendarEventMaybeResponse(
        accountId,
        null,
        maybe: [EventId(blobId.value)]);
      when(calendarEventRepository.maybeEventInvitation(any, any))
        .thenAnswer((_) async => calendarEventMaybeResponse);

      // assert
      expect(
        maybeCalendarEventInteractor.execute(accountId, {blobId}, emailId),
        emitsInOrder([
          Right(CalendarEventMaybeReplying()),
          Right(CalendarEventMaybeSuccess(calendarEventMaybeResponse, emailId))]));
    });

    test('when repo throw exception', () {
      // arrange
      final exception = NotMaybeableCalendarEventException();
      when(calendarEventRepository.maybeEventInvitation(any, any)).thenThrow(exception);

      // assert
      expect(
        maybeCalendarEventInteractor.execute(accountId, {blobId}, emailId),
        emitsInOrder([
          Right(CalendarEventMaybeReplying()),
          Left(CalendarEventMaybeFailure(exception: exception))]));
    });
  });
}