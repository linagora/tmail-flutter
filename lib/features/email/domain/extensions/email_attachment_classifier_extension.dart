import 'package:html/parser.dart' show parse;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/extensions/list_email_content_extension.dart';

class PresentationAttachments {
  final List<Attachment> attachments;
  final List<Attachment> inlineImages;

  const PresentationAttachments({
    required this.attachments,
    required this.inlineImages,
  });
}

extension EmailAttachmentClassifierExtension on Email {
  PresentationAttachments classifyAttachments() {
    // Cache: allAttachments getter re-allocates on each call.
    final allAttachmentsSnapshot = allAttachments;
    final outsideAttachments = allAttachmentsSnapshot.getListAttachmentsDisplayedOutside(htmlBodyAttachments);
    final allInlineImages = allAttachmentsSnapshot.listAttachmentsDisplayedInContent;
    final referencedCids = _extractReferencedCids(emailContentList.asHtmlString);
    final inlineImages = <Attachment>[];
    final orphanedInlineImages = <Attachment>[];
    for (final a in allInlineImages) {
      (referencedCids.contains(a.cid) ? inlineImages : orphanedInlineImages).add(a);
    }
    // Dedupe: undefined-disposition + cid attachments satisfy both
    // isOutsideAttachment and listAttachmentsDisplayedInContent predicates.
    // Without this filter the same blob would render twice in the panel.
    final orphanBlobIds = orphanedInlineImages.map((a) => a.blobId).toSet();
    final outsideOnly = outsideAttachments
      .where((a) => !orphanBlobIds.contains(a.blobId))
      .toList();
    return PresentationAttachments(
      attachments: [...outsideOnly, ...orphanedInlineImages],
      inlineImages: inlineImages,
    );
  }
}

Set<String> _extractReferencedCids(String htmlContent) {
  if (htmlContent.isEmpty) return {};
  try {
    return parse(htmlContent)
      .querySelectorAll('img[src^="cid:"]')
      .map((img) => img.attributes['src']?.substring('cid:'.length).trim())
      .nonNulls
      .toSet();
  } catch (_) {
    return {};
  }
}
