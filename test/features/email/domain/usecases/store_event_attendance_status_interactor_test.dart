import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_event_attendance_status_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_event_attendance_status_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

import 'store_event_attendance_status_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>()
])
void main() {
  group('StoreEventAttendanceStatusInteractor test', () {
    late MockEmailRepository mockEmailRepository;
    late StoreEventAttendanceStatusInteractor storeEventAttendanceStatusInteractor;

    setUp(() {
      mockEmailRepository = MockEmailRepository();
      storeEventAttendanceStatusInteractor = StoreEventAttendanceStatusInteractor(mockEmailRepository);
    });

    final sessionFixture = SessionFixtures.aliceSession;
    final accountIdFixture = AccountFixtures.aliceAccountId;
    final emailIdFixture = EmailFixtures.emailId;
    const eventActionType = EventActionType.yes;

    test('SHOULD emit loading and success states when storeEventAttendanceStatus is successful', () async {
      final updatedEmail = Email(id: emailIdFixture);

      when(mockEmailRepository.storeEventAttendanceStatus(
        sessionFixture,
        accountIdFixture,
        emailIdFixture,
        eventActionType
      )).thenAnswer((_) async => updatedEmail);

      final result = storeEventAttendanceStatusInteractor.execute(
        sessionFixture,
        accountIdFixture,
        emailIdFixture,
        eventActionType);

      await expectLater(
        result,
        emitsInOrder([
          Right(StoreEventAttendanceStatusLoading()),
          Right(StoreEventAttendanceStatusSuccess(eventActionType)),
        ]),
      );

      verify(mockEmailRepository.storeEventAttendanceStatus(
        sessionFixture,
        accountIdFixture,
        emailIdFixture,
        eventActionType
      )).called(1);
      verifyNoMoreInteractions(mockEmailRepository);
    });

    test('SHOULD emit loading and failure states when storeEventAttendanceStatus throws an exception', () async {
      final exception = Exception();

      when(mockEmailRepository.storeEventAttendanceStatus(
        sessionFixture,
        accountIdFixture,
        emailIdFixture,
        eventActionType,
      )).thenThrow(exception);

      final result = storeEventAttendanceStatusInteractor.execute(
        sessionFixture,
        accountIdFixture,
        emailIdFixture,
        eventActionType);

      await expectLater(
        result,
        emitsInOrder([
          Right(StoreEventAttendanceStatusLoading()),
          Left(StoreEventAttendanceStatusFailure(exception: exception)),
        ]),
      );
    });
  });
}