import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/restore_deleted_message_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'restore_deleted_message_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>()])
void main() {
  group('RestoredDeletedMessageInteractor::execute::', () {
    late MockEmailRepository emailRepository;
    late RestoredDeletedMessageInteractor interactor;

    setUp(() {
      emailRepository = MockEmailRepository();
      interactor = RestoredDeletedMessageInteractor(emailRepository);
    });

    test('the success carries the account the restore started on, not my own', () async {
      final request = RestoredDeletedMessageRequest(Id('create-id'), EmailRecoveryAction());
      final emailRecovery = EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-id')));
      when(emailRepository.restoreDeletedMessage(request)).thenAnswer((_) async => emailRecovery);

      await expectLater(
        interactor.execute(DelegationFixtures.session(), DelegationFixtures.bobAccountId, request),
        emitsInOrder([
          Right<Failure, Success>(RestoreDeletedMessageLoading()),
          Right<Failure, Success>(RestoreDeletedMessageSuccess(emailRecovery, DelegationFixtures.bobAccountId)),
          emitsDone,
        ]),
      );
    });
  });
}
