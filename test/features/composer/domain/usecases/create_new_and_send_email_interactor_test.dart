import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'create_new_and_send_email_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<MailboxRepository>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  final emailRepository = MockEmailRepository();
  final mailboxRepository = MockMailboxRepository();
  final composerRepository = MockComposerRepository();
  final createNewAndSendEmailInteractor = CreateNewAndSendEmailInteractor(
    emailRepository,
    mailboxRepository,
    composerRepository);
  group('create new and send email interactor test:', () {
    test(
      'should call generateEmail from composerRepository with withIdentityHeader is false '
      'when execute is called',
    () async {
      // arrange
      final createEmailRequest = CreateEmailRequest(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailActionType: EmailActionType.editDraft,
        subject: 'subject',
        emailContent: 'emailContent',
        fromSender: {},
        toRecipients: {},
        ccRecipients: {},
        bccRecipients: {},
        replyToRecipients: {},
      );
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader')))
        .thenAnswer((_) async => Email());
      
      // act
      createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .last;
      await untilCalled(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader')));
      
      // assert
      verify(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: false)
      ).called(1);
    });
  });
}