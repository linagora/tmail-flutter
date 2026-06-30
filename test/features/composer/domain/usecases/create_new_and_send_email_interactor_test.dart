import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'create_new_and_send_email_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  final emailRepository = MockEmailRepository();
  final composerRepository = MockComposerRepository();
  final createNewAndSendEmailInteractor = CreateNewAndSendEmailInteractor(
    emailRepository,
    composerRepository);

  CreateEmailRequest buildCreateEmailRequest({EmailId? draftsEmailId}) {
    return CreateEmailRequest(
      session: SessionFixtures.aliceSession,
      accountId: AccountFixtures.aliceAccountId,
      emailActionType: EmailActionType.editDraft,
      ownEmailAddress: SessionFixtures
        .aliceSession
        .getOwnEmailAddressOrEmpty(),
      subject: 'subject',
      emailContent: 'emailContent',
      draftsEmailId: draftsEmailId,
    );
  }

  setUp(() {
    reset(emailRepository);
    reset(composerRepository);
    when(composerRepository.generateEmail(
      any,
      withIdentityHeader: anyNamed('withIdentityHeader'),
      isDraft: anyNamed('isDraft'),
    )).thenAnswer((_) async => Email());
  });

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
        ownEmailAddress: SessionFixtures
          .aliceSession
          .getOwnEmailAddressOrEmpty(),
        subject: 'subject',
        emailContent: 'emailContent',
      );
      when(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader'),
        isDraft: anyNamed('isDraft'),
      )).thenAnswer((_) async => Email());
      
      // act
      createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .last;
      await untilCalled(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader'),
        isDraft: anyNamed('isDraft'),
      ));
      
      // assert
      verify(composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: false,
        isDraft: false,
      )).called(1);
    });

    test(
      'should emit GenerateEmailLoading, SendEmailLoading and SendEmailSuccess '
      'and call sendEmail when sending succeeds',
    () async {
      // arrange
      final createEmailRequest = buildCreateEmailRequest();
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenAnswer((_) async {});

      // act
      final states = await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      final successStates = states
        .whereType<Right>()
        .map((right) => right.value)
        .toList();
      expect(
        successStates.map((state) => state.runtimeType).toList(),
        equals([
          GenerateEmailLoading,
          SendEmailLoading,
          SendEmailSuccess,
        ]),
      );
      verify(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).called(1);
    });

    test(
      'should emit SendEmailFailure carrying the thrown exception '
      'when sendEmail throws',
    () async {
      // arrange
      final createEmailRequest = buildCreateEmailRequest();
      final exception = Exception('send failed');
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenThrow(exception);

      // act
      final states = await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      final failure = states
        .whereType<Left>()
        .map((left) => left.value)
        .whereType<SendEmailFailure>()
        .firstOrNull;
      expect(failure, isNotNull);
      expect(failure!.exception, exception);
    });

    test(
      'should propagate the sending context on SendEmailFailure '
      'when sendEmail throws',
    () async {
      // arrange
      final createEmailRequest = buildCreateEmailRequest();
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenThrow(Exception('send failed'));

      // act
      final states = await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      final failure = states
        .whereType<Left>()
        .map((left) => left.value)
        .whereType<SendEmailFailure>()
        .first;
      expect(failure.session, SessionFixtures.aliceSession);
      expect(failure.accountId, AccountFixtures.aliceAccountId);
      expect(failure.emailRequest, isNotNull);
    });

    test(
      'should emit GenerateEmailFailure and not call sendEmail '
      'when the email object cannot be created',
    () async {
      // arrange
      final createEmailRequest = buildCreateEmailRequest();
      when(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader'),
        isDraft: anyNamed('isDraft'),
      )).thenThrow(Exception('cannot generate email'));

      // act
      final states = await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      final failure = states
        .whereType<Left>()
        .map((left) => left.value)
        .whereType<GenerateEmailFailure>()
        .firstOrNull;
      expect(failure, isNotNull);
      expect(failure!.exception, isA<CannotCreateEmailObjectException>());
      verifyNever(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      ));
    });

    test(
      'should not delete any draft after sending '
      'when emailIdDestroyed is not set',
    () async {
      // arrange
      final createEmailRequest = buildCreateEmailRequest();
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenAnswer((_) async {});

      // act
      await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      verifyNever(emailRepository.deleteEmailPermanently(any, any, any));
    });

    test(
      'should still emit SendEmailSuccess '
      'when deleting the old draft fails',
    () async {
      // arrange
      final draftsEmailId = EmailId(Id('draft-email-id'));
      final createEmailRequest = buildCreateEmailRequest(
        draftsEmailId: draftsEmailId,
      );
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenAnswer((_) async {});
      when(emailRepository.deleteEmailPermanently(
        any,
        any,
        any,
      )).thenThrow(Exception('delete draft failed'));

      // act
      final states = await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      final successStates = states
        .whereType<Right>()
        .map((right) => right.value)
        .toList();
      expect(states.whereType<Left>(), isEmpty);
      expect(successStates.last, isA<SendEmailSuccess>());
      verify(emailRepository.deleteEmailPermanently(
        any,
        any,
        draftsEmailId,
      )).called(1);
    });

    test(
      'should delete the old draft after sending '
      'when emailIdDestroyed is set',
    () async {
      // arrange
      final draftsEmailId = EmailId(Id('draft-email-id'));
      final createEmailRequest = buildCreateEmailRequest(
        draftsEmailId: draftsEmailId,
      );
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenAnswer((_) async {});
      when(emailRepository.deleteEmailPermanently(
        any,
        any,
        any,
      )).thenAnswer((_) async => true);

      // act
      await createNewAndSendEmailInteractor
        .execute(createEmailRequest: createEmailRequest)
        .toList();

      // assert
      verify(emailRepository.deleteEmailPermanently(
        any,
        any,
        draftsEmailId,
      )).called(1);
    });
  });
}