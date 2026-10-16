import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

void main() {
  final accountId = AccountFixtures.aliceAccountId;
  final interactor = CheckSendingAllowedInteractor();

  group('CheckSendingAllowedInteractor::execute', () {
    test('SHOULD allow sending WHEN the session has no SaaS capability',
        () async {
      await expectLater(
        interactor.execute(SessionFixtures.aliceSession, accountId),
        completes,
      );
    });

    test(
      'SHOULD allow sending '
      'WHEN the session says the mail DNS configuration is validated',
    () async {
      await expectLater(
        interactor.execute(
          SessionFixtures.getAliceSessionWithSaaSCapability(
            mailDnsConfigurationValidated: true,
          ),
          accountId,
        ),
        completes,
      );
    });

    test(
      'SHOULD throw ForbiddenToSendException '
      'WHEN the session says the domain is pending',
    () async {
      await expectLater(
        interactor.execute(
          SessionFixtures.getAliceSessionWithSaaSCapability(
            mailDnsConfigurationValidated: false,
          ),
          accountId,
        ),
        throwsA(isA<ForbiddenToSendException>()
            .having((e) => e.createdEmailId, 'createdEmailId', isNull)
            .having((e) => e.mapErrors, 'mapErrors', isEmpty)),
      );
    });
  });
}
