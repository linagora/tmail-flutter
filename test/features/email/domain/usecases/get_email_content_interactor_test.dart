import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

import 'get_email_content_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>()])
void main() {
  late MockEmailRepository mockEmailRepository;
  late GetEmailContentInteractor interactor;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  final emailId = EmailId(Id('test-email-id'));
  const baseDownloadUrl = 'https://download.example.com/';
  final transformConfig = TransformConfiguration.forPreviewEmailOnWeb();

  setUp(() {
    mockEmailRepository = MockEmailRepository();
    interactor = GetEmailContentInteractor(mockEmailRepository);
  });

  // Helper: build EmailBodyPart for a regular (external) attachment
  EmailBodyPart makeExternalAttachment({required String blobIdValue, String? name}) =>
      EmailBodyPart(blobId: Id(blobIdValue), disposition: 'attachment', name: name);

  // Helper: build EmailBodyPart for an inline attachment with a cid
  EmailBodyPart makeInlineAttachment({required String blobIdValue, required String cid}) =>
      EmailBodyPart(blobId: Id(blobIdValue), cid: cid, disposition: 'inline');

  // Helper: build an Email with given attachments and an optional HTML body string
  Email makeEmail({Set<EmailBodyPart>? attachments, String htmlContent = ''}) {
    if (htmlContent.isEmpty) {
      return Email(id: emailId, attachments: attachments);
    }
    return Email(
      id: emailId,
      attachments: attachments,
      htmlBody: {
        EmailBodyPart(partId: PartId('1'), type: MediaType('text', 'html')),
      },
      bodyValues: {
        PartId('1'): EmailBodyValue(
          value: htmlContent,
          isEncodingProblem: false,
          isTruncated: false,
        ),
      },
    );
  }

  // Helper: stub transformEmailContent so the stream can proceed past email content processing
  void stubTransform() {
    when(mockEmailRepository.transformEmailContent(any, any, any))
        .thenAnswer((_) async => []);
  }

  // Helper: extract GetEmailContentSuccess from stream results
  Future<GetEmailContentSuccess> runAndGetSuccess() async {
    final results = await interactor
        .execute(session, accountId, emailId, baseDownloadUrl, transformConfig)
        .toList();
    return results
        .whereType<Right<Failure, Success>>()
        .map((r) => r.value)
        .whereType<GetEmailContentSuccess>()
        .first;
  }

  // Helper: stub + run a single inline-attachment scenario and return the success state
  Future<GetEmailContentSuccess> runWithInlinePart({
    required String cid,
    required String blobIdValue,
    required String htmlContent,
  }) async {
    final inlinePart = makeInlineAttachment(blobIdValue: blobIdValue, cid: cid);
    when(mockEmailRepository.getEmailContent(session, accountId, emailId))
        .thenAnswer((_) async => makeEmail(attachments: {inlinePart}, htmlContent: htmlContent));
    stubTransform();
    return runAndGetSuccess();
  }

  group('GetEmailContentInteractor::classifyAttachments::', () {
    test('no attachments: both lists are empty', () async {
      final email = makeEmail();
      when(mockEmailRepository.getEmailContent(session, accountId, emailId))
          .thenAnswer((_) async => email);
      stubTransform();

      final success = await runAndGetSuccess();

      expect(success.attachments, isEmpty);
      expect(success.inlineImages, isEmpty);
    });

    test('external attachment only: appears in attachments, not inlineImages', () async {
      final extPart = makeExternalAttachment(blobIdValue: 'blob-ext', name: 'doc.pdf');
      when(mockEmailRepository.getEmailContent(session, accountId, emailId))
          .thenAnswer((_) async => makeEmail(attachments: {extPart}));
      stubTransform();

      final success = await runAndGetSuccess();

      expect(success.attachments, hasLength(1));
      expect(success.attachments!.first.blobId, equals(Id('blob-ext')));
      expect(success.inlineImages, isEmpty);
    });

    for (final tc in [
      (
        description: 'referenced inline image: appears in inlineImages, not attachments',
        cid: 'referenced-cid@domain',
        blobId: 'blob-inline',
        expectInline: true,
      ),
      (
        description: 'orphaned inline image: promoted to attachments, not inlineImages',
        cid: 'orphan-cid@domain',
        blobId: 'blob-orphan',
        expectInline: false,
      ),
    ]) {
      final htmlContent = tc.expectInline
          ? '<img src="cid:${tc.cid}">'
          : '<p>No cid reference here</p>';

      test(tc.description, () async {
        final success = await runWithInlinePart(
          cid: tc.cid,
          blobIdValue: tc.blobId,
          htmlContent: htmlContent,
        );
        final populated = tc.expectInline ? success.inlineImages : success.attachments;
        final empty = tc.expectInline ? success.attachments : success.inlineImages;
        expect(populated, hasLength(1));
        expect(populated!.first.cid, equals(tc.cid));
        expect(empty, isEmpty);
      });
    }

    test('empty html body: inline image with cid treated as orphaned', () async {
      const cid = 'some-cid@domain';
      final inlinePart = makeInlineAttachment(blobIdValue: 'blob-inline', cid: cid);
      // No htmlContent → emailContentList is empty → _extractReferencedCids returns {}
      when(mockEmailRepository.getEmailContent(session, accountId, emailId))
          .thenAnswer((_) async => makeEmail(attachments: {inlinePart}));
      stubTransform();

      final success = await runAndGetSuccess();

      expect(success.attachments, hasLength(1));
      expect(success.inlineImages, isEmpty);
    });

    test('mixed: external + referenced + orphaned are correctly partitioned', () async {
      const referencedCid = 'referenced@domain';
      const orphanedCid = 'orphan@domain';
      final extPart = makeExternalAttachment(blobIdValue: 'blob-ext', name: 'report.pdf');
      final referencedPart = makeInlineAttachment(blobIdValue: 'blob-ref', cid: referencedCid);
      final orphanedPart = makeInlineAttachment(blobIdValue: 'blob-orphan', cid: orphanedCid);
      when(mockEmailRepository.getEmailContent(session, accountId, emailId))
          .thenAnswer((_) async => makeEmail(
            attachments: {extPart, referencedPart, orphanedPart},
            htmlContent: '<img src="cid:$referencedCid">',
          ));
      stubTransform();

      final success = await runAndGetSuccess();

      // attachments = external + orphaned (2 items)
      expect(success.attachments, hasLength(2));
      final attachmentBlobIds = success.attachments!.map((a) => a.blobId).toSet();
      expect(attachmentBlobIds, containsAll([Id('blob-ext'), Id('blob-orphan')]));

      // inlineImages = referenced only (1 item)
      expect(success.inlineImages, hasLength(1));
      expect(success.inlineImages!.first.cid, equals(referencedCid));
    });
  });
}
