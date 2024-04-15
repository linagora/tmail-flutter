import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_accept_interactor.dart';

import 'calendar_event_accept_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CalendarEventRepository>()])
void main() {
  final calendarEventRepository = MockCalendarEventRepository();
  final acceptCalendarEventInteractor = AcceptCalendarEventInteractor(calendarEventRepository);
  final accountId = AccountId(Id('123'));
  final blobId = Id('123321');

  group('calendar event accept interactor test:', () {
    test('should emit CalendarEventAccepted when repo return data', () {
      // arrange
      final calendarEventAcceptResponse = CalendarEventAcceptResponse(
        accountId,
        null,
        accepted: [EventId(blobId.value)]);
      when(calendarEventRepository.acceptEventInvitation(any, any))
        .thenAnswer((_) async => calendarEventAcceptResponse);

      // assert
      expect(
        acceptCalendarEventInteractor.execute(accountId, {blobId}),
        emitsInOrder([
          Right(CalendarEventAccepting()),
          Right(CalendarEventAccepted(calendarEventAcceptResponse))]));
    });

    test('should emit CalendarEventAcceptFailure when repo throw exception', () {
      // arrange
      final exception = NotAcceptableCalendarEventException();
      when(calendarEventRepository.acceptEventInvitation(any, any)).thenThrow(exception);

      // assert
      expect(
        acceptCalendarEventInteractor.execute(accountId, {blobId}),
        emitsInOrder([
          Right(CalendarEventAccepting()),
          Left(CalendarEventAcceptFailure(exception: exception))]));
    });
  });
}