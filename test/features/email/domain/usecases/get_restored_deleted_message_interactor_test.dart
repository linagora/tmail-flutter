import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/email_recovery_status.dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_restored_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'get_restored_deleted_message_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>(), MockSpec<MailboxRepository>()])
void main() {
  group('GetRestoredDeletedMessageInterator::execute::', () {
    final session = DelegationFixtures.session();
    final restoringAccountId = DelegationFixtures.bobAccountId;
    final emailRecoveryActionId = EmailRecoveryActionId(Id('recovery-id'));

    late MockEmailRepository emailRepository;
    late MockMailboxRepository mailboxRepository;
    late GetRestoredDeletedMessageInterator interactor;

    setUp(() {
      emailRepository = MockEmailRepository();
      mailboxRepository = MockMailboxRepository();
      interactor = GetRestoredDeletedMessageInterator(emailRepository, mailboxRepository);
    });

    EmailRecoveryAction stubRecovery(EmailRecoveryStatus status) {
      final emailRecovery = EmailRecoveryAction(id: emailRecoveryActionId, status: status);
      when(emailRepository.getRestoredDeletedMessage(emailRecoveryActionId))
          .thenAnswer((_) async => emailRecovery);
      return emailRecovery;
    }

    test('a completed restore looks up the recovered folder and carries the account it started on', () async {
      final emailRecovery = stubRecovery(EmailRecoveryStatus.completed);
      final recoveredMailbox = Mailbox(id: MailboxId(Id('recovered-id')));
      when(mailboxRepository.getMailboxByRole(session, restoringAccountId, Role('Restored-Messages')))
          .thenAnswer((_) async => GetMailboxByRoleResponse(mailbox: recoveredMailbox));

      await expectLater(
        interactor.execute(session, restoringAccountId, emailRecoveryActionId),
        emitsInOrder([
          Right<Failure, Success>(GetRestoredDeletedMessageLoading()),
          Right<Failure, Success>(GetRestoredDeletedMessageCompleted(
            emailRecovery,
            restoringAccountId,
            recoveredMailbox: recoveredMailbox,
          )),
          emitsDone,
        ]),
      );
    });

    final pendingStates = {
      EmailRecoveryStatus.inProgress: (EmailRecoveryAction emailRecovery) =>
          GetRestoredDeletedMessageInProgress(emailRecovery, restoringAccountId),
      EmailRecoveryStatus.waiting: (EmailRecoveryAction emailRecovery) =>
          GetRestoredDeletedMessageWaiting(emailRecovery, restoringAccountId),
      EmailRecoveryStatus.canceled: (EmailRecoveryAction emailRecovery) =>
          GetRestoredDeletedMessageCanceled(emailRecovery, restoringAccountId),
    };
    pendingStates.forEach((status, expectedState) {
      test('a restore with status ${status.name} carries the account it started on, not my own', () async {
        final emailRecovery = stubRecovery(status);

        await expectLater(
          interactor.execute(session, restoringAccountId, emailRecoveryActionId),
          emitsInOrder([
            Right<Failure, Success>(GetRestoredDeletedMessageLoading()),
            Right<Failure, Success>(expectedState(emailRecovery)),
            emitsDone,
          ]),
        );
      });
    });
  });
}
