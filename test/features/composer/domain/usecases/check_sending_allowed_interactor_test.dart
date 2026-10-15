import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'check_sending_allowed_interactor_test.mocks.dart';

final _accountId = AccountFixtures.aliceAccountId;
final _pendingSession = SessionFixtures.getAliceSessionWithSaaSCapability(
  mailDnsConfigurationValidated: false,
);
final _validatedSession = SessionFixtures.getAliceSessionWithSaaSCapability(
  mailDnsConfigurationValidated: true,
);

@GenerateNiceMocks([MockSpec<SessionRepository>()])
void main() {
  final sessionRepository = MockSessionRepository();
  final interactor = CheckSendingAllowedInteractor(sessionRepository);

  setUp(() => reset(sessionRepository));

  group('CheckSendingAllowedInteractor::execute', () {
    _validatedSessionTests(sessionRepository, interactor);
    _pendingSessionTests(sessionRepository, interactor);
  });
}

void _validatedSessionTests(
  MockSessionRepository sessionRepository,
  CheckSendingAllowedInteractor interactor,
) {
  test(
    'SHOULD allow sending without fetching the session '
    'WHEN the session has no SaaS capability',
  () async {
    await expectLater(
      interactor.execute(SessionFixtures.aliceSession, _accountId),
      completes,
    );
    verifyNever(sessionRepository.getSession());
  });

  test(
    'SHOULD allow sending without fetching the session '
    'WHEN the session says the mail DNS configuration is validated',
  () async {
    await expectLater(
      interactor.execute(_validatedSession, _accountId),
      completes,
    );
    verifyNever(sessionRepository.getSession());
  });
}

void _pendingSessionTests(
  MockSessionRepository sessionRepository,
  CheckSendingAllowedInteractor interactor,
) {
  test(
    'SHOULD throw ForbiddenToSendException '
    'WHEN the cached and the latest session both say the domain is pending',
  () async {
    when(sessionRepository.getSession())
        .thenAnswer((_) async => _pendingSession);

    await expectLater(
      interactor.execute(_pendingSession, _accountId),
      throwsA(isA<ForbiddenToSendException>()
          .having((e) => e.createdEmailId, 'createdEmailId', isNull)
          .having((e) => e.mapErrors, 'mapErrors', isEmpty)),
    );
    verify(sessionRepository.getSession()).called(1);
  });

  test(
    'SHOULD allow sending '
    'WHEN the cached session is pending but the latest one is validated',
  () async {
    when(sessionRepository.getSession())
        .thenAnswer((_) async => _validatedSession);

    await expectLater(interactor.execute(_pendingSession, _accountId), completes);
    verify(sessionRepository.getSession()).called(1);
  });

  test(
    'SHOULD allow sending '
    'WHEN the cached session is pending but the latest one has no SaaS capability',
  () async {
    when(sessionRepository.getSession())
        .thenAnswer((_) async => SessionFixtures.aliceSession);

    await expectLater(interactor.execute(_pendingSession, _accountId), completes);
  });

  test(
    'SHOULD allow sending, leaving the server to refuse it '
    'WHEN the cached session is pending and fetching the latest one fails',
  () async {
    when(sessionRepository.getSession()).thenThrow(Exception('network down'));

    await expectLater(interactor.execute(_pendingSession, _accountId), completes);
    verify(sessionRepository.getSession()).called(1);
  });
}
