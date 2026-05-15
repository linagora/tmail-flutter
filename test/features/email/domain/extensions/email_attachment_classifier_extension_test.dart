import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_attachment_classifier_extension.dart';

void main() {
  EmailBodyPart externalPart({required String blobIdValue, String? name}) =>
      EmailBodyPart(blobId: Id(blobIdValue), disposition: 'attachment', name: name);

  EmailBodyPart inlinePart({
    required String blobIdValue,
    required String cid,
    String? disposition = 'inline',
  }) =>
      EmailBodyPart(blobId: Id(blobIdValue), cid: cid, disposition: disposition);

  Email buildEmail({Set<EmailBodyPart>? attachments, String htmlContent = ''}) {
    if (htmlContent.isEmpty) {
      return Email(id: EmailId(Id('e')), attachments: attachments);
    }
    return Email(
      id: EmailId(Id('e')),
      attachments: attachments,
      htmlBody: {EmailBodyPart(partId: PartId('1'), type: MediaType('text', 'html'))},
      bodyValues: {
        PartId('1'): EmailBodyValue(value: htmlContent, isEncodingProblem: false, isTruncated: false),
      },
    );
  }

  // Asserts the partition by extracting blobIds for attachments and cids for inlines.
  void expectPartition(
    PresentationAttachments result, {
    required Set<String> attachmentBlobIds,
    required Set<String> inlineCids,
  }) {
    expect(result.attachments.map((a) => a.blobId?.value).toSet(), attachmentBlobIds);
    expect(result.inlineImages.map((a) => a.cid).toSet(), inlineCids);
  }

  group('EmailAttachmentClassifierExtension::classifyAttachments::', () {
    test('no attachments returns empty lists', () {
      expectPartition(
        buildEmail().toPresentationAttachments(),
        attachmentBlobIds: {},
        inlineCids: {},
      );
    });

    test('external attachment goes to attachments only', () {
      final email = buildEmail(attachments: {externalPart(blobIdValue: 'b', name: 'doc.pdf')});
      expectPartition(
        email.toPresentationAttachments(),
        attachmentBlobIds: {'b'},
        inlineCids: {},
      );
    });

    // Single-inline cases: each row is one Email with one inline attachment;
    // the body either references its cid (→ inlineImages) or doesn't (→ attachments).
    for (final tc in [
      (
        name: 'referenced (cid present in body) goes to inlineImages',
        cid: 'ref@x',
        body: '<img src="cid:ref@x">',
        expectedAttachmentBlobs: <String>{},
        expectedInlineCids: {'ref@x'},
      ),
      (
        name: 'orphaned (cid not in body) is promoted to attachments',
        cid: 'orphan@x',
        body: '<p>no images here</p>',
        expectedAttachmentBlobs: {'b'},
        expectedInlineCids: <String>{},
      ),
      (
        name: 'cid: src with whitespace is trimmed before matching',
        cid: 'ref@x',
        body: '<img src="cid:  ref@x  ">',
        expectedAttachmentBlobs: <String>{},
        expectedInlineCids: {'ref@x'},
      ),
    ]) {
      test(tc.name, () {
        final email = buildEmail(
          attachments: {inlinePart(blobIdValue: 'b', cid: tc.cid)},
          htmlContent: tc.body,
        );
        expectPartition(
          email.toPresentationAttachments(),
          attachmentBlobIds: tc.expectedAttachmentBlobs,
          inlineCids: tc.expectedInlineCids,
        );
      });
    }

    test('mixed: external + referenced + orphaned partition correctly', () {
      final email = buildEmail(
        attachments: {
          externalPart(blobIdValue: 'ext', name: 'doc.pdf'),
          inlinePart(blobIdValue: 'ref', cid: 'ref@x'),
          inlinePart(blobIdValue: 'orphan', cid: 'orphan@x'),
        },
        htmlContent: '<img src="cid:ref@x">',
      );
      expectPartition(
        email.toPresentationAttachments(),
        attachmentBlobIds: {'ext', 'orphan'},
        inlineCids: {'ref@x'},
      );
    });

    test('empty body: all inlines treated as orphaned', () {
      // No htmlBody/bodyValues → emailContentList is empty → asHtmlString = ''
      final email = buildEmail(attachments: {inlinePart(blobIdValue: 'b', cid: 'c@x')});
      expectPartition(
        email.toPresentationAttachments(),
        attachmentBlobIds: {'b'},
        inlineCids: {},
      );
    });

    test('malformed HTML: classifier must not crash', () {
      // The html package is lenient; this test pins down the catch branch
      // so future parser swaps don't propagate exceptions to callers.
      final email = buildEmail(
        attachments: {inlinePart(blobIdValue: 'b', cid: 'c@x')},
        htmlContent: '<<<>>>not html<<<',
      );
      expect(() => email.toPresentationAttachments(), returnsNormally);
    });

    test('inline disposition without cid is excluded from inline list', () {
      // hasCid() filter in listAttachmentsDisplayedInContent skips this entry;
      // it falls through to outside (noCid() → isOutsideAttachment).
      final email = buildEmail(
        attachments: {EmailBodyPart(blobId: Id('b'), disposition: 'inline')},
        htmlContent: '<p>text</p>',
      );
      expectPartition(
        email.toPresentationAttachments(),
        attachmentBlobIds: {'b'},
        inlineCids: {},
      );
    });

    test('undefined disposition + cid (orphan) appears once, not duplicated', () {
      // Regression guard: undefined+cid satisfies BOTH isOutsideAttachment and
      // listAttachmentsDisplayedInContent predicates. Must dedupe by blobId.
      final email = buildEmail(
        attachments: {inlinePart(blobIdValue: 'b', cid: 'c@x', disposition: null)},
        htmlContent: '<p>no cid ref</p>',
      );
      expectPartition(
        email.toPresentationAttachments(),
        attachmentBlobIds: {'b'},
        inlineCids: {},
      );
    });
  });
}
