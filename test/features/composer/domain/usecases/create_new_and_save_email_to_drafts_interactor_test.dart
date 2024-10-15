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
import 'package:tmail_ui_user/features/login/data/network/interceptors/timeout_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'create_new_and_save_email_to_drafts_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<MailboxRepository>(),
  MockSpec<ComposerRepository>(),
  MockSpec<TimeoutInterceptors>(),
])
void main() {
  late MockEmailRepository emailRepository;
  late MockMailboxRepository mailboxRepository;
  late MockComposerRepository composerRepository;
  late MockTimeoutInterceptors timeoutInterceptors;
  late CreateNewAndSaveEmailToDraftsInteractor createNewAndSaveEmailToDraftsInteractor;

  setUp(() {
    emailRepository = MockEmailRepository();
    mailboxRepository = MockMailboxRepository();
    composerRepository = MockComposerRepository();
    timeoutInterceptors = MockTimeoutInterceptors();
    createNewAndSaveEmailToDraftsInteractor = CreateNewAndSaveEmailToDraftsInteractor(
      emailRepository,
      mailboxRepository,
      composerRepository,
      timeoutInterceptors,
    );
  });
  
  group('CreateNewAndSaveEmailToDraftsInteractor::test:', () {
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

    test(
      'SHOULD call `resetTimeout` on success for save email as drafts\n'
      'WHEN `enableTimeout` is true',
    () async {
      // Arrange
      final createEmailRequest = CreateEmailRequest(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailActionType: EmailActionType.compose,
        subject: 'subject',
        emailContent: 'emailContent',
        fromSender: {},
        toRecipients: {},
        ccRecipients: {},
        bccRecipients: {},
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.saveEmailAsDrafts(
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenAnswer((_) async => email);

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.savingMessageTimeout,
        sendTimeout: AppConfig.savingMessageTimeout,
        receiveTimeout: AppConfig.savingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test(
      'SHOULD call `resetTimeout` on success for update email drafts\n'
      'WHEN `enableTimeout` is true',
    () async {
      // Arrange
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
        draftsEmailId: EmailId(Id('draft-email-id')),
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.updateEmailDrafts(
        any,
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenAnswer((_) async => email);

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.savingMessageTimeout,
        sendTimeout: AppConfig.savingMessageTimeout,
        receiveTimeout: AppConfig.savingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test(
      'SHOULD call `resetTimeout` on failure for save email as drafts\n'
      'WHEN `enableTimeout` is true',
    () async {
      // Arrange
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
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.saveEmailAsDrafts(
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenThrow(Exception());

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.savingMessageTimeout,
        sendTimeout: AppConfig.savingMessageTimeout,
        receiveTimeout: AppConfig.savingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test(
      'SHOULD call `resetTimeout` on failure for update email drafts\n'
      'WHEN `enableTimeout` is true',
    () async {
      // Arrange
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
        draftsEmailId: EmailId(Id('draft-email-id')),
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.updateEmailDrafts(
        any,
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenThrow(Exception());

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.savingMessageTimeout,
        sendTimeout: AppConfig.savingMessageTimeout,
        receiveTimeout: AppConfig.savingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test(
      'SHOULD call `resetTimeout` on success for save email as drafts\n'
      'WHEN `enableTimeout` is false',
    () async {
      // Arrange
      final createEmailRequest = CreateEmailRequest(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailActionType: EmailActionType.compose,
        subject: 'subject',
        emailContent: 'emailContent',
        fromSender: {},
        toRecipients: {},
        ccRecipients: {},
        bccRecipients: {},
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.saveEmailAsDrafts(
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenAnswer((_) async => email);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });

    test(
      'SHOULD call `resetTimeout` on success for update email drafts\n'
      'WHEN `enableTimeout` is false',
    () async {
      // Arrange
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
        draftsEmailId: EmailId(Id('draft-email-id')),
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.updateEmailDrafts(
        any,
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenAnswer((_) async => email);

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });

    test(
      'SHOULD call `resetTimeout` on failure for save email as drafts\n'
      'WHEN `enableTimeout` is false',
    () async {
      // Arrange
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
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.saveEmailAsDrafts(
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenThrow(Exception());

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });

    test(
      'SHOULD call `resetTimeout` on failure for update email drafts\n'
      'WHEN `enableTimeout` is false',
    () async {
      // Arrange
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
        draftsEmailId: EmailId(Id('draft-email-id')),
      );
      final email = Email(id: EmailId(Id('draft-id')));

      when(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true
      )).thenAnswer((_) async => email);

      when(emailRepository.updateEmailDrafts(
        any,
        any,
        any,
        any,
        cancelToken: anyNamed('cancelToken')
      )).thenThrow(Exception());

      // Act
      final result = createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });
  });
}