import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:uuid/uuid.dart';

import 'composer_repository_impl_test.mocks.dart';

@GenerateMocks([
  AttachmentUploadDataSource,
  ComposerDataSource,
  HtmlDataSource,
  ApplicationManager,
  Uuid,
  CreateEmailRequest,
  Session,
  Identity,
])
void main() {
  group('ComposerRepositoryImpl::generateEmail::', () {
    late ComposerRepositoryImpl repository;
    late MockAttachmentUploadDataSource mockAttachmentUploadDataSource;
    late MockComposerDataSource mockComposerDataSource;
    late MockHtmlDataSource mockHtmlDataSource;
    late MockApplicationManager mockApplicationManager;
    late MockUuid mockUuid;
    late MockCreateEmailRequest mockCreateEmailRequest;
    late MockSession mockSession;
    late MockIdentity mockIdentity;

    setUp(() {
      mockAttachmentUploadDataSource = MockAttachmentUploadDataSource();
      mockComposerDataSource = MockComposerDataSource();
      mockHtmlDataSource = MockHtmlDataSource();
      mockApplicationManager = MockApplicationManager();
      mockUuid = MockUuid();
      mockCreateEmailRequest = MockCreateEmailRequest();
      mockSession = MockSession();
      mockIdentity = MockIdentity();

      when(mockSession.username).thenReturn(UserName('test@example.com'));
      when(mockIdentity.email).thenReturn('identity@example.com');
      when(mockIdentity.name).thenReturn('Test User');
      when(mockIdentity.replyTo).thenReturn({});

      when(mockCreateEmailRequest.session).thenReturn(mockSession);
      when(mockCreateEmailRequest.identity).thenReturn(mockIdentity);
      when(mockCreateEmailRequest.replyToRecipients).thenReturn({});

      repository = ComposerRepositoryImpl(
        mockAttachmentUploadDataSource,
        mockComposerDataSource,
        mockHtmlDataSource,
        mockApplicationManager,
        mockUuid,
      );
    });

    test(
      'When the email content contains base64 images,\n'
      'generateEmail should replace them with CIDs and return an email without base64',
    () async {
      // Arrange
      const base64Image =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
      const emailContentWithBase64 = '<p>Hello <img src="$base64Image" alt="test image"></p>';
      const emailContentWithCid = '<p>Hello <img src="cid:unique-cid" alt="test image"></p>';
      const userAgent = 'TestUserAgent';
      const partIdValue = 'part-id-123';
      final inlineAttachments = {
        'unique-cid': Attachment(name: 'test.png'),
      };
      final attachments = [Attachment(name: 'test.png')];
      final emailBodyParts = {
        EmailBodyPart(partId: PartId(partIdValue), type: MediaType('image', 'png')),
      };

      when(mockCreateEmailRequest.emailContent).thenReturn(emailContentWithBase64);
      when(mockCreateEmailRequest.inlineAttachments).thenReturn(inlineAttachments);
      when(mockCreateEmailRequest.uploadUri).thenReturn(Uri.parse('https://example.com/upload'));
      when(mockCreateEmailRequest.attachments).thenReturn(attachments);
      when(mockCreateEmailRequest.toRecipients).thenReturn({});
      when(mockCreateEmailRequest.ccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.bccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.subject).thenReturn('Test Subject');
      when(mockCreateEmailRequest.draftsMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.outboxMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.emailActionType).thenReturn(EmailActionType.compose);
      when(mockCreateEmailRequest.hasRequestReadReceipt).thenReturn(false);
      when(mockCreateEmailRequest.isMarkAsImportant).thenReturn(false);
      when(mockCreateEmailRequest.templateMailboxId).thenReturn(null);

      when(mockHtmlDataSource.replaceImageBase64ToImageCID(
        emailContent: emailContentWithBase64,
        inlineAttachments: inlineAttachments,
        uploadUri: Uri.parse('https://example.com/upload'),
      )).thenAnswer((_) async => Tuple2(emailContentWithCid, emailBodyParts));

      when(mockHtmlDataSource.removeCollapsedExpandedSignatureEffect(emailContent: emailContentWithCid))
          .thenAnswer((_) async => emailContentWithCid);

      when(mockApplicationManager.generateApplicationUserAgent())
          .thenAnswer((_) async => userAgent);

      when(mockUuid.v1()).thenReturn(partIdValue);

      // Act
      final result = await repository.generateEmail(mockCreateEmailRequest);

      // Assert
      expect(result, isA<Email>());
      expect(result.from, {EmailAddress('Test User', 'identity@example.com')});
      expect(result.bodyValues![PartId(partIdValue)]!.value, emailContentWithCid);
      expect(result.attachments, containsAll(emailBodyParts));
      expect(emailContentWithCid.contains('data:image'), isFalse);
      verify(mockHtmlDataSource.replaceImageBase64ToImageCID(
        emailContent: emailContentWithBase64,
        inlineAttachments: inlineAttachments,
        uploadUri: Uri.parse('https://example.com/upload'),
      )).called(1);
    });

    test(
      'When replacing base64 with CID fails,\n'
      'generateEmail should still successfully create an email with the original content',
    () async {
      // Arrange
      const emailContentWithBase64 = '<p>Hello <img src="data:image/png;base64,abc123" alt="test"></p>';
      const userAgent = 'TestUserAgent';
      const partIdValue = 'part-id-123';
      final inlineAttachments = {
        'cid-1': Attachment(name: 'test.png'),
      };
      final attachments = [Attachment(name: 'test.png')];

      when(mockCreateEmailRequest.emailContent).thenReturn(emailContentWithBase64);
      when(mockCreateEmailRequest.inlineAttachments).thenReturn(inlineAttachments);
      when(mockCreateEmailRequest.uploadUri).thenReturn(Uri.parse('https://example.com/upload'));
      when(mockCreateEmailRequest.attachments).thenReturn(attachments);
      when(mockCreateEmailRequest.toRecipients).thenReturn({});
      when(mockCreateEmailRequest.ccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.bccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.subject).thenReturn('Test Subject');
      when(mockCreateEmailRequest.draftsMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.outboxMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.emailActionType).thenReturn(EmailActionType.compose);
      when(mockCreateEmailRequest.hasRequestReadReceipt).thenReturn(false);
      when(mockCreateEmailRequest.isMarkAsImportant).thenReturn(false);
      when(mockCreateEmailRequest.templateMailboxId).thenReturn(null);

      when(mockHtmlDataSource.replaceImageBase64ToImageCID(
        emailContent: emailContentWithBase64,
        inlineAttachments: inlineAttachments,
        uploadUri: Uri.parse('https://example.com/upload'),
      )).thenThrow(Exception('Failed to replace base64'));

      when(mockHtmlDataSource.removeCollapsedExpandedSignatureEffect(emailContent: emailContentWithBase64))
          .thenAnswer((_) async => emailContentWithBase64);

      when(mockApplicationManager.generateApplicationUserAgent())
          .thenAnswer((_) async => userAgent);

      when(mockUuid.v1()).thenReturn(partIdValue);

      // Act
      final result = await repository.generateEmail(mockCreateEmailRequest);

      // Assert
      expect(result, isA<Email>());
      expect(result.bodyValues![PartId(partIdValue)]!.value, emailContentWithBase64);
      expect(result.attachments, isNotEmpty);
      verify(mockHtmlDataSource.replaceImageBase64ToImageCID(
        emailContent: emailContentWithBase64,
        inlineAttachments: inlineAttachments,
        uploadUri: Uri.parse('https://example.com/upload'),
      )).called(1);
    });

    test(
      'When the email content has no base64 images,\n'
      'generateEmail should process it correctly and return a valid email',
    () async {
      const plainEmailContent = '<p>Hello, this is a simple email</p>';
      const userAgent = 'TestUserAgent';
      const partIdValue = 'part-id-123';
      final attachments = [Attachment(name: 'test.png')];
      final emailBodyParts = {
        EmailBodyPart(partId: PartId(partIdValue), type: MediaType('image', 'png')),
      };

      when(mockCreateEmailRequest.emailContent).thenReturn(plainEmailContent);
      when(mockCreateEmailRequest.inlineAttachments).thenReturn({});
      when(mockCreateEmailRequest.uploadUri).thenReturn(Uri.parse('https://example.com/upload'));
      when(mockCreateEmailRequest.attachments).thenReturn(attachments);
      when(mockCreateEmailRequest.toRecipients).thenReturn({});
      when(mockCreateEmailRequest.ccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.bccRecipients).thenReturn(null);
      when(mockCreateEmailRequest.subject).thenReturn('Test Subject');
      when(mockCreateEmailRequest.draftsMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.outboxMailboxId).thenReturn(null);
      when(mockCreateEmailRequest.emailActionType).thenReturn(EmailActionType.compose);
      when(mockCreateEmailRequest.hasRequestReadReceipt).thenReturn(false);
      when(mockCreateEmailRequest.isMarkAsImportant).thenReturn(false);
      when(mockCreateEmailRequest.templateMailboxId).thenReturn(null);

      when(mockHtmlDataSource.replaceImageBase64ToImageCID(
        emailContent: plainEmailContent,
        inlineAttachments: {},
        uploadUri: Uri.parse('https://example.com/upload'),
      )).thenAnswer((_) async => Tuple2(plainEmailContent, emailBodyParts));

      when(mockHtmlDataSource.removeCollapsedExpandedSignatureEffect(emailContent: plainEmailContent))
          .thenAnswer((_) async => plainEmailContent);

      when(mockApplicationManager.generateApplicationUserAgent())
          .thenAnswer((_) async => userAgent);

      when(mockUuid.v1()).thenReturn(partIdValue);

      final result = await repository.generateEmail(mockCreateEmailRequest);

      expect(result, isA<Email>());
      expect(result.bodyValues![PartId(partIdValue)]!.value, plainEmailContent);
      expect(result.attachments, containsAll(emailBodyParts));
    });
  });
}