/// Turns image URLs into inline SVGs of a known size so a fixture renders
/// with no network access.
///
/// `https://fixture.invalid/{img|cid}/<W>x<H>` (written by
/// `tool/eml_to_fixture.py`) becomes a W x H SVG. Any other remote URL in a
/// resource attribute ([_resourceAttributes], `data-src` included because
/// `AddLazyLoadingForBackgroundImageTransformer` moves backgrounds there), in
/// a `style` attribute or in a `<style>` block becomes the converter's
/// 600 x 300 default. Visible text, text attributes, links and `data:` values
/// are left untouched. `DisplayFrame` checks
/// afterwards that nothing was fetched.
library;

const defaultOfflineImageSize = (width: 600, height: 300);

final _placeholder = RegExp(r'https://fixture\.invalid/(?:img|cid)/(\d+)x(\d+)');
final _remote = RegExp(r'''(?:https?:)?//[^\s"'<>)]+''', caseSensitive: false);
// A tag, with `>` allowed inside quoted attribute values.
final _tag = RegExp(r'''<(?:[^>"']|"[^"]*"|'[^']*')*>''');
final _attribute = RegExp(r'''(\s)([^\s=/>]+)(\s*=\s*)("[^"]*"|'[^']*')''');
final _cssUrl = RegExp(r'''url\(\s*(['"]?)([^'")]+)\1\s*\)''', caseSensitive: false);
final _cssImport = RegExp(r'''@import\s+(['"])([^'"]+)\1''', caseSensitive: false);

/// A W x H SVG as a data URI. `'` is percent-encoded too, so the URI also
/// survives inside `url('…')` (the lazy-background script writes that).
String offlineSvgDataUri(int width, int height) =>
    'data:image/svg+xml,${Uri.encodeComponent(
      "<svg xmlns='http://www.w3.org/2000/svg' width='$width' height='$height' "
      "viewBox='0 0 $width $height'><rect width='100%' height='100%' "
      "fill='#c8c8c8'/></svg>",
    ).replaceAll("'", '%27')}';

bool _isRemote(String url) =>
    !url.trimLeft().toLowerCase().startsWith('data:') && _remote.hasMatch(url);

String _offlineUrl(String url) {
  final placeholder = _placeholder.firstMatch(url);
  if (placeholder != null) {
    return offlineSvgDataUri(
      int.parse(placeholder.group(1)!),
      int.parse(placeholder.group(2)!),
    );
  }
  return offlineSvgDataUri(
    defaultOfflineImageSize.width,
    defaultOfflineImageSize.height,
  );
}

String _swapCss(String css) => css
    .replaceAllMapped(_cssUrl, (match) {
      final url = match.group(2)!.trim();
      if (!_isRemote(url)) return match.group(0)!;
      return 'url(${match.group(1)}${_offlineUrl(url)}${match.group(1)})';
    })
    .replaceAllMapped(_cssImport, (match) {
      if (!_isRemote(match.group(2)!)) return match.group(0)!;
      return '@import ${match.group(1)}data:text/css,${match.group(1)}';
    });

const _resourceAttributes = {
  'src', 'srcset', 'background', 'data-src', 'poster', 'lowsrc', 'dynsrc',
};

/// Attributes that make the page fetch something. Links stay links, except
/// SVG `<image href>` (and `xlink:href`), which loads an image.
bool _loadsResource(String tagName, String attribute) =>
    _resourceAttributes.contains(attribute) ||
    attribute == 'style' ||
    (tagName == 'image' && (attribute == 'href' || attribute == 'xlink:href'));

String _swapTag(String tag) {
  final tagName =
      RegExp(r'^<\s*([^\s/>]+)').firstMatch(tag)?.group(1)?.toLowerCase() ?? '';
  return tag.replaceAllMapped(_attribute, (match) {
    final name = match.group(2)!.toLowerCase();
    final quoted = match.group(4)!;
    final quote = quoted[0];
    final value = quoted.substring(1, quoted.length - 1);
    if (!_loadsResource(tagName, name) ||
        value.trimLeft().toLowerCase().startsWith('data:')) {
      return match.group(0)!;
    }
    final swapped = name == 'style'
        ? _swapCss(value)
        : value.replaceAllMapped(_remote, (url) => _offlineUrl(url.group(0)!));
    return '${match.group(1)}${match.group(2)}${match.group(3)}'
        '$quote$swapped$quote';
  });
}

String swapImagesForOffline(String html) {
  final buffer = StringBuffer();
  var position = 0;
  var inStyle = false;
  for (final match in _tag.allMatches(html)) {
    final text = html.substring(position, match.start);
    final tag = match.group(0)!;
    buffer
      ..write(inStyle ? _swapCss(text) : text)
      ..write(_swapTag(tag));
    final lower = tag.toLowerCase();
    if (RegExp(r'^<style[\s>]').hasMatch(lower)) inStyle = true;
    if (lower.startsWith('</style')) inStyle = false;
    position = match.end;
  }
  final tail = html.substring(position);
  buffer.write(inStyle ? _swapCss(tail) : tail);
  return buffer.toString();
}
