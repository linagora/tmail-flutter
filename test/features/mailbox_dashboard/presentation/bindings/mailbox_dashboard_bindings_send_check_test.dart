import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

class _MockEmailRepository extends Mock implements EmailRepository {}

class _RefusingCheckSendingAllowedInteractor
    implements CheckSendingAllowedInteractor {
  @override
  Future<void> execute(Session session, AccountId accountId) async =>
      throw ForbiddenToSendException();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test(
    'SHOULD build SendEmailInteractor with the registered send check',
  () async {
    Get.put<EmailRepository>(_MockEmailRepository());
    Get.put<CheckSendingAllowedInteractor>(
      _RefusingCheckSendingAllowedInteractor(),
    );

    MailboxDashBoardBindings().bindingsInteractor();

    final states = await Get.find<SendEmailInteractor>()
        .execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          EmailRequest(email: Email(), emailActionType: EmailActionType.compose),
        )
        .toList();

    expect(
      states.last.fold((failure) => failure, (success) => success),
      isA<SendEmailFailure>().having(
        (failure) => failure.exception,
        'exception',
        isA<ForbiddenToSendException>(),
      ),
    );
  });
}
