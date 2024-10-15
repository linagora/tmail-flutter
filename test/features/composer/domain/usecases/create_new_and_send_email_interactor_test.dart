
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/timeout_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'create_new_and_send_email_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<MailboxRepository>(),
  MockSpec<ComposerRepository>(),
  MockSpec<TimeoutInterceptors>(),
])
void main() {
  final emailRepository = MockEmailRepository();
  final mailboxRepository = MockMailboxRepository();
  final composerRepository = MockComposerRepository();
  final timeoutInterceptors = MockTimeoutInterceptors();
  final createNewAndSendEmailInteractor = CreateNewAndSendEmailInteractor(
    emailRepository,
    mailboxRepository,
    composerRepository,
    timeoutInterceptors,
  );

  group('CreateNewAndSendEmailInteractor::test:', () {
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

    test(
      'should call generateEmail from composerRepository with withIdentityHeader is false '
      'when execute is called',
    () async {
      // arrange
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

    test('SHOULD call `resetTimeout` on success WHEN `enableTimeout` is true', () async {
      // Arrange
      when(composerRepository.generateEmail(createEmailRequest)).thenAnswer((_) async => Email());

      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Future.value());

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.sendingMessageTimeout,
        sendTimeout: AppConfig.sendingMessageTimeout,
        receiveTimeout: AppConfig.sendingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSendEmailInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test('SHOULD call `resetTimeout` on failure WHEN `enableTimeout` is true', () async {
      // Arrange
      when(composerRepository.generateEmail(createEmailRequest)).thenAnswer((_) async => Email());

      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(Exception());

      when(timeoutInterceptors.setTimeout(
        connectionTimeout: AppConfig.sendingMessageTimeout,
        sendTimeout: AppConfig.sendingMessageTimeout,
        receiveTimeout: AppConfig.sendingMessageTimeout,
      )).thenReturn(null);

      // Act
      final result = createNewAndSendEmailInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: true,
      );

      await result.last;

      // Assert
      verify(timeoutInterceptors.resetTimeout()).called(1);
    });

    test('SHOULD not call `resetTimeout` on success WHEN `enableTimeout` is false', () async {
      // Arrange
      when(composerRepository.generateEmail(createEmailRequest)).thenAnswer((_) async => Email());

      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Future.value());

      // Act
      final result = createNewAndSendEmailInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });

    test('SHOULD not call `resetTimeout` on failure WHEN `enableTimeout` is false', () async {
      // Arrange
      when(composerRepository.generateEmail(createEmailRequest)).thenAnswer((_) async => Email());

      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(Exception());

      // Act
      final result = createNewAndSendEmailInteractor.execute(
        createEmailRequest: createEmailRequest,
        enableTimeout: false,
      );

      await result.last;

      // Assert
      verifyNever(timeoutInterceptors.resetTimeout());
    });
  });
}