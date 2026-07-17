import 'dart:convert';

/// Card sizing for [FileLinkCardHtmlBuilder.buildFileLinkCard].
class FileLinkCardSize {
  const FileLinkCardSize({
    this.cardWidthPx = 183,
    this.cardMinHeightPx = 151,
  });

  final int cardWidthPx;
  final int cardMinHeightPx;
}

/// Content for [FileLinkCardHtmlBuilder.buildFileLinkCard].
class FileLinkCardContent {
  const FileLinkCardContent({
    required this.href,
    required this.title,
    required this.actionLabel,
    required this.iconZoneHtml,
  });

  final String href;
  final String title;
  final String actionLabel;
  final String iconZoneHtml;
}

/// Builds the inline HTML card used to represent a linked file (e.g. a Drive
/// attachment) inside the composer body.
class FileLinkCardHtmlBuilder {
  static const _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  static const _textEscape = HtmlEscape();

  static String buildFileLinkCard(
    FileLinkCardContent content, {
    FileLinkCardSize size = const FileLinkCardSize(),
  }) {
    final safeHref = _attributeEscape.convert(content.href);
    final safeTitle = _textEscape.convert(content.title);
    final safeActionLabel = _textEscape.convert(content.actionLabel);

    return '<a href="$safeHref" target="_blank" rel="noopener noreferrer" contenteditable="false" tabindex="-1" class="tmail-file-link-card" style="display:inline-block;vertical-align:top;width:${size.cardWidthPx}px;'
        'min-height:${size.cardMinHeightPx}px;margin:0 8px 8px 0;border:1px solid #E5E7EB;'
        'border-radius:10px;overflow:hidden;background:#FFFFFF;color:inherit;text-decoration:none;">'
        '${content.iconZoneHtml}'
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

  static String wrapFileCardsHtml(List<String> cards) {
    if (cards.isEmpty) return '';
    // The row div is left editable (not contenteditable="false") so each
    // card stays individually selectable/deletable as an atomic unit -
    // browsers already let you select and Backspace a non-editable child
    // without entering it. Enter anywhere inside this row is handled by
    // HtmlUtils.registerFileLinkRowEnterKeyHandler, which recognizes the row
    // by its direct contenteditable="false" <a> children and redirects the
    // caret to the trailing <p><br></p> below instead of letting the
    // editor's native (card-unaware) paragraph-split run.
    return '<div style="display:block;max-width:100%;">${cards.join()}</div><p><br></p>';
  }
}
