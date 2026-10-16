import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

void main() {
  final accountId = AccountFixtures.aliceAccountId;
  final interactor = CheckSendingAllowedInteractor();

  group('CheckSendingAllowedInteractor::execute', () {
    test('SHOULD allow sending WHEN the session has no SaaS capability', () {
      expect(
        () => interactor.execute(SessionFixtures.aliceSession, accountId),
        returnsNormally,
      );
    });

    test(
      'SHOULD allow sending '
      'WHEN the session says the mail DNS configuration is validated',
    () {
      expect(
        () => interactor.execute(
          SessionFixtures.getAliceSessionWithSaaSCapability(
            mailDnsConfigurationValidated: true,
          ),
          accountId,
        ),
        returnsNormally,
      );
    });

    test(
      'SHOULD throw ForbiddenToSendException '
      'WHEN the session says the domain is pending',
    () {
      expect(
        () => interactor.execute(
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
