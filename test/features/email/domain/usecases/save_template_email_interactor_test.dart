import 'package:core/presentation/state/failure.dart';
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
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/save_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/update_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/save_template_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'save_template_email_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  late MockEmailRepository emailRepository;
  late MockComposerRepository composerRepository;
  late SaveTemplateEmailInteractor interactor;

  final templateEmailId = EmailId(Id('template-id'));

  CreateEmailRequest buildRequest({EmailId? templateEmailId}) => CreateEmailRequest(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    emailActionType: EmailActionType.compose,
    ownEmailAddress: SessionFixtures.aliceSession.getOwnEmailAddressOrEmpty(),
    subject: 'subject',
    emailContent: 'emailContent',
    templateEmailId: templateEmailId,
  );

  Future<List<dynamic>> executeInteractor({EmailId? templateEmailId}) =>
      interactor
          .execute(
            createEmailRequest: buildRequest(templateEmailId: templateEmailId),
            createNewMailboxRequest: null,
          )
          .toList();

  T? firstSuccess<T>(List results) => results
      .whereType<Right>()
      .map((r) => r.value)
      .whereType<T>()
      .firstOrNull;

  T? firstFailure<T>(List results) => results
      .whereType<Left>()
      .map((l) => l.value)
      .whereType<T>()
      .firstOrNull;

  void expectNotFoundEmailIdException<T extends FeatureFailure>(List results) {
    final failure = firstFailure<T>(results);
    expect(failure, isNotNull);
    expect(failure!.exception, isA<NotFoundEmailIdException>());
  }

  void stubGenerateEmailSuccess() {
    when(composerRepository.generateEmail(
      any,
      withIdentityHeader: anyNamed('withIdentityHeader'),
      isTemplate: anyNamed('isTemplate'),
    )).thenAnswer((_) async => Email());
  }

  setUp(() {
    emailRepository = MockEmailRepository();
    composerRepository = MockComposerRepository();
    interactor = SaveTemplateEmailInteractor(composerRepository, emailRepository);
  });

  group('SaveTemplateEmailInteractor:', () {
    group('_createEmailObject fails:', () {
      test(
        'should emit GenerateEmailFailure(CannotCreateEmailObjectException) when generateEmail throws',
      () async {
        when(composerRepository.generateEmail(
          any,
          withIdentityHeader: anyNamed('withIdentityHeader'),
          isTemplate: anyNamed('isTemplate'),
        )).thenThrow(Exception('generate failed'));

        final results = await executeInteractor();

        final failure = firstFailure<GenerateEmailFailure>(results);
        expect(failure, isNotNull);
        expect(failure!.exception, isA<CannotCreateEmailObjectException>());
      });
    });

    group('_saveEmailAsTemplate (templateEmailId == null):', () {
      setUp(stubGenerateEmailSuccess);

      test(
        'should emit SaveTemplateEmailSuccess with correct emailId',
      () async {
        when(emailRepository.saveEmailAsTemplate(any, any, any))
            .thenAnswer((_) async => Email(id: EmailId(Id('new-template-id'))));

        final results = await executeInteractor();

        final success = firstSuccess<SaveTemplateEmailSuccess>(results);
        expect(success, isNotNull);
        expect(success!.emailId, EmailId(Id('new-template-id')));
      });

      test(
        'should emit SaveTemplateEmailFailure(NotFoundEmailIdException) when server returns email with null id',
      () async {
        when(emailRepository.saveEmailAsTemplate(any, any, any))
            .thenAnswer((_) async => Email()); // id is null

        final results = await executeInteractor();

        expectNotFoundEmailIdException<SaveTemplateEmailFailure>(results);
      });

      test(
        'should emit SaveTemplateEmailFailure when repository throws',
      () async {
        when(emailRepository.saveEmailAsTemplate(any, any, any))
            .thenThrow(Exception('network error'));

        final results = await executeInteractor();

        final failure = firstFailure<SaveTemplateEmailFailure>(results);
        expect(failure, isNotNull);
      });
    });

    group('_updateTemplateEmail (templateEmailId != null):', () {
      setUp(stubGenerateEmailSuccess);

      test(
        'should emit UpdateTemplateEmailSuccess with attachments from server response',
      () async {
        final attachment = EmailBodyPart(
          blobId: Id('blob-123'),
          name: 'file.png',
          type: MediaType('image', 'png'),
        );
        final inlinePart = EmailBodyPart(
          blobId: Id('blob-inline'),
          cid: 'cid-1',
          type: MediaType('image', 'png'),
        );
        final serverEmail = Email(
          id: EmailId(Id('updated-id')),
          attachments: {attachment},
          htmlBody: {inlinePart},
        );

        when(emailRepository.updateEmailTemplate(any, any, any, any))
            .thenAnswer((_) async => serverEmail);

        final results = await executeInteractor(templateEmailId: templateEmailId);

        final success = firstSuccess<UpdateTemplateEmailSuccess>(results);
        expect(success, isNotNull);
        expect(success!.emailId, EmailId(Id('updated-id')));
        expect(success.attachments, hasLength(1));
        expect(success.attachments.first.blobId?.value, 'blob-123');
        expect(success.htmlBodyAttachments, hasLength(1));
        expect(success.htmlBodyAttachments.first.blobId?.value, 'blob-inline');
      });

      test(
        'should emit UpdateTemplateEmailFailure(NotFoundEmailIdException) when server returns email with null id',
      () async {
        when(emailRepository.updateEmailTemplate(any, any, any, any))
            .thenAnswer((_) async => Email()); // id is null

        final results = await executeInteractor(templateEmailId: templateEmailId);

        expectNotFoundEmailIdException<UpdateTemplateEmailFailure>(results);
      });

      test(
        'should emit UpdateTemplateEmailFailure when repository throws',
      () async {
        when(emailRepository.updateEmailTemplate(any, any, any, any))
            .thenThrow(Exception('network error'));

        final results = await executeInteractor(templateEmailId: templateEmailId);

        final failure = firstFailure<UpdateTemplateEmailFailure>(results);
        expect(failure, isNotNull);
      });

      test(
        'should call updateEmailTemplate with correct templateEmailId',
      () async {
        when(emailRepository.updateEmailTemplate(any, any, any, any))
            .thenAnswer((_) async => Email(id: EmailId(Id('updated-id'))));

        await executeInteractor(templateEmailId: templateEmailId);

        verify(emailRepository.updateEmailTemplate(
          any, any, any, templateEmailId,
        )).called(1);
      });
    });
  });
}
