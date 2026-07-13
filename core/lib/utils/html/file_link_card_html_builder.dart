import 'dart:convert';

/// Builds the inline HTML card used to represent a linked file (e.g. a Drive
/// attachment) inside the composer body.
class FileLinkCardHtmlBuilder {
  static const _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  static const _textEscape = HtmlEscape();

  static String buildFileLinkCard({
    required String href,
    required String title,
    required String actionLabel,
    required String iconZoneHtml,
    int cardWidthPx = 183,
    int cardMinHeightPx = 151,
  }) {
    final safeHref = _attributeEscape.convert(href);
    final safeTitle = _textEscape.convert(title);
    final safeActionLabel = _textEscape.convert(actionLabel);

    return '<a href="$safeHref" target="_blank" rel="noopener noreferrer" contenteditable="false" tabindex="-1" style="display:inline-block;vertical-align:top;width:${cardWidthPx}px;'
        'min-height:${cardMinHeightPx}px;margin:0 8px 8px 0;border:1px solid #E5E7EB;'
        'border-radius:10px;overflow:hidden;background:#FFFFFF;color:inherit;text-decoration:none;">'
        '$iconZoneHtml'
        '<div style="padding:10px 12px;">'
        '<div style="font-size:14px;font-weight:500;color:#1F2937;white-space:nowrap;'
        'overflow:hidden;text-overflow:ellipsis;" title="$safeTitle">$safeTitle</div>'
        '<div style="display:block;margin-top:6px;font-size:12px;'
        'color:#0A84FF;white-space:nowrap;overflow:hidden;'
        'text-overflow:ellipsis;">$safeActionLabel ↗</div>'
        '</div>'
        '</a>';
  }

  static String buildFileCardIconZone({
    String? imageUrl,
    int iconZoneHeightPx = 94,
    int iconSizePx = 60,
  }) {
    final content = imageUrl == null || imageUrl.isEmpty
        ? ''
        : '<img src="${_attributeEscape.convert(imageUrl)}" width="$iconSizePx" height="$iconSizePx" '
            'style="display:inline-block;vertical-align:middle;" />';
    return '<div style="height:${iconZoneHeightPx}px;line-height:${iconZoneHeightPx}px;'
        'text-align:center;background:#F5F6F8;border-bottom:1px solid #E5E7EB;">'
        '$content'
        '</div>';
  }

  static String wrapFileCardsHtml(String cardsHtml) {
    if (cardsHtml.isEmpty) return '';
    return '<div style="display:block;max-width:100%;">$cardsHtml</div><br>';
  }
}
