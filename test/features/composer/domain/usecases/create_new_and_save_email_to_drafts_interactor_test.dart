import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';

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
  late CreateNewAndSaveEmailToDraftsInteractor interactor;

  final draftEmailId = EmailId(Id('draft-id'));

  CreateEmailRequest buildRequest({EmailId? draftsEmailId}) => CreateEmailRequest(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    emailActionType: EmailActionType.editDraft,
    ownEmailAddress: SessionFixtures.aliceSession.getOwnEmailAddressOrEmpty(),
    subject: 'subject',
    emailContent: 'emailContent',
    draftsEmailId: draftsEmailId,
  );

  setUp(() {
    emailRepository = MockEmailRepository();
    composerRepository = MockComposerRepository();
    interactor = CreateNewAndSaveEmailToDraftsInteractor(emailRepository, composerRepository);
  });

  group('create new and save email to drafts interactor test:', () {
    test(
      'should call generateEmail with withIdentityHeader=true when draftsEmailId != null',
    () async {
      final request = buildRequest(draftsEmailId: draftEmailId);
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.updateEmailDrafts(any, any, any, any))
          .thenAnswer((_) async => Email());

      interactor.execute(createEmailRequest: request).last;
      await untilCalled(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')));

      verify(composerRepository.generateEmail(request, withIdentityHeader: true, isDraft: true)).called(1);
    });

    test(
      'should call generateEmail with withIdentityHeader=true when draftsEmailId == null',
    () async {
      final request = buildRequest();
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.saveEmailAsDrafts(any, any, any))
          .thenAnswer((_) async => Email());

      interactor.execute(createEmailRequest: request).last;
      await untilCalled(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')));

      verify(composerRepository.generateEmail(request, withIdentityHeader: true, isDraft: true)).called(1);
    });
  });

  group('_updateDraftsEmail:', () {
    test(
      'should emit UpdateEmailDraftsSuccess with attachments from server response',
    () async {
      final attachment = EmailBodyPart(
        blobId: Id('blob-123'),
        name: 'file.png',
        type: MediaType('image', 'png'),
      );
      final serverEmail = Email(
        id: EmailId(Id('new-id')),
        attachments: {attachment},
      );

      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.updateEmailDrafts(any, any, any, any))
          .thenAnswer((_) async => serverEmail);

      final results = await interactor
          .execute(createEmailRequest: buildRequest(draftsEmailId: draftEmailId))
          .toList();

      final successState = results
          .whereType<Right>()
          .map((r) => r.value)
          .whereType<UpdateEmailDraftsSuccess>()
          .firstOrNull;

      expect(successState, isNotNull);
      expect(successState!.emailId, EmailId(Id('new-id')));
      expect(successState.attachments, hasLength(1));
      expect(successState.attachments.first.blobId?.value, 'blob-123');
    });

    test(
      'should emit UpdateEmailDraftsFailure(NotFoundEmailIdException) when server returns email with null id',
    () async {
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.updateEmailDrafts(any, any, any, any))
          .thenAnswer((_) async => Email()); // id is null

      final results = await interactor
          .execute(createEmailRequest: buildRequest(draftsEmailId: draftEmailId))
          .toList();

      final failure = results
          .whereType<Left>()
          .map((l) => l.value)
          .whereType<UpdateEmailDraftsFailure>()
          .firstOrNull;

      expect(failure, isNotNull);
      expect(failure!.exception, isA<NotFoundEmailIdException>());
    });
  });

  group('_handleFailure:', () {
    test(
      'should emit UpdateEmailDraftsFailure(SavingEmailToDraftsCanceledException) '
      'when UnknownRemoteException wraps a list of SavingEmailToDraftsCanceledException',
    () async {
      final wrappedException = UnknownRemoteException(
        error: [SavingEmailToDraftsCanceledException()],
      );
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.updateEmailDrafts(any, any, any, any))
          .thenThrow(wrappedException);

      final results = await interactor
          .execute(createEmailRequest: buildRequest(draftsEmailId: draftEmailId))
          .toList();

      final failure = results
          .whereType<Left>()
          .map((l) => l.value)
          .whereType<UpdateEmailDraftsFailure>()
          .firstOrNull;

      expect(failure, isNotNull);
      expect(failure!.exception, isA<SavingEmailToDraftsCanceledException>());
    });

    test(
      'should emit SaveEmailAsDraftsFailure(SavingEmailToDraftsCanceledException) '
      'when UnknownRemoteException wraps a list of SavingEmailToDraftsCanceledException '
      'and draftsEmailId is null',
    () async {
      final wrappedException = UnknownRemoteException(
        error: [SavingEmailToDraftsCanceledException()],
      );
      when(composerRepository.generateEmail(any, withIdentityHeader: anyNamed('withIdentityHeader'), isDraft: anyNamed('isDraft')))
          .thenAnswer((_) async => Email());
      when(emailRepository.saveEmailAsDrafts(any, any, any))
          .thenThrow(wrappedException);

      final results = await interactor
          .execute(createEmailRequest: buildRequest())
          .toList();

      final failure = results
          .whereType<Left>()
          .map((l) => l.value)
          .whereType<SaveEmailAsDraftsFailure>()
          .firstOrNull;

      expect(failure, isNotNull);
      expect(failure!.exception, isA<SavingEmailToDraftsCanceledException>());
    });
  });
}
