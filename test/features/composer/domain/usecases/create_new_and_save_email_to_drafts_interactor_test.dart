import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'create_new_and_save_email_to_drafts_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  late MockEmailRepository emailRepository;
  late MockComposerRepository composerRepository;
  late CreateNewAndSaveEmailToDraftsInteractor createNewAndSaveEmailToDraftsInteractor;

  setUp(() {
    emailRepository = MockEmailRepository();
    composerRepository = MockComposerRepository();
    createNewAndSaveEmailToDraftsInteractor = CreateNewAndSaveEmailToDraftsInteractor(
      emailRepository,
      composerRepository);
  });
  
  group('create new and save email to drafts interactor test:', () {
    test(
      'should call generateEmail from composerRepository with withIdentityHeader is true '
      'when execute is called '
      'and draftsEmailId != null',
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
        draftsEmailId: EmailId(Id('some-id'))
      );
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader')))
        .thenAnswer((_) async => Email());
      when(emailRepository.updateEmailDrafts(any, any, any, any))
        .thenAnswer((_) async => Email());
      
      // act
      createNewAndSaveEmailToDraftsInteractor
        .execute(createEmailRequest: createEmailRequest)
        .last;
      await untilCalled(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader')));
      
      // assert
      verify(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true)
      ).called(1);
    });

    test(
      'should call generateEmail from composerRepository with withIdentityHeader is true '
      'when execute is called '
      'and draftsEmailId == null',
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
      when(emailRepository.saveEmailAsDrafts(any, any, any))
        .thenAnswer((_) async => Email());
      
      // act
      createNewAndSaveEmailToDraftsInteractor
        .execute(createEmailRequest: createEmailRequest)
        .last;
      await untilCalled(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader')));
      
      // assert
      verify(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true)
      ).called(1);
    });
  });
}