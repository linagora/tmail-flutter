import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:model/email/attachment.dart';

const String inlineImageCidPrefix = 'cid:';

/// Synchronous inline-image matching, keyed by cid. The send path adds uploads
/// on top; the reload snapshot uses it alone because it cannot await.
extension InlineImageCidExtension on Map<String, Attachment> {
  /// Points an uploaded base64 `<img id="cid:X">` at `cid:X`.
  Attachment? resolveUploadedImage(Map<Object, String> imgAttributes) {
    final id = imgAttributes['id'];
    if (id == null || !id.startsWith(inlineImageCidPrefix)) return null;

    final cid = id.substring(inlineImageCidPrefix.length).trim();
    final attachment = this[cid];
    if (attachment == null) return null;

    imgAttributes['src'] = '$inlineImageCidPrefix$cid';
    imgAttributes.remove('id');
    return attachment;
  }

  /// Inline attachments already referenced by `<img src="cid:X">` tags.
  Iterable<Attachment> referencedBy(Iterable<Element> cidImgTags) => cidImgTags
      .map((img) => img.attributes['src'])
      .nonNulls
      .map((src) => this[src.substring(inlineImageCidPrefix.length).trim()])
      .nonNulls;

  /// Rewrites uploaded base64 images to `cid:` and returns the inline
  /// attachments the HTML references. Unmatched base64 images stay inline.
  (String html, Set<Attachment> inlineImages) replaceUploadedImagesWithCid(
    String html,
  ) {
    final document = parse(html);
    final base64ImgTags = document.querySelectorAll('img[src^="data:image/"]');
    final cidImgTags = document.querySelectorAll('img[src^="$inlineImageCidPrefix"]');

    final inlineImages = {
      ...base64ImgTags.map((img) => resolveUploadedImage(img.attributes)).nonNulls,
      ...referencedBy(cidImgTags),
    };
    if (inlineImages.isEmpty) return (html, const {});

    return (document.body?.innerHtml ?? html, inlineImages);
  }
}
