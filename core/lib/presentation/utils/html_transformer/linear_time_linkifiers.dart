import 'package:linkify/linkify.dart';

/// Same output as [EmailLinkifier], in linear time.
///
/// The package anchors `^(.*?)` before the address and recurses on the rest,
/// so a long run of local-part characters without a valid address costs
/// quadratic time. Here one pass consumes each run whole and the address tail
/// is optional, so a failed run is never rescanned from its inner positions.
class LinearTimeEmailLinkifier extends Linkifier {
  static final _localPartRunRegex = RegExp(
    r'(mailto:)?[A-Z0-9._%+-]+(@[A-Z0-9.-]+\.[A-Z][A-Z]+)?',
    caseSensitive: false,
  );
  static const _mailtoPrefix = 'mailto:';
  static final _mailtoRegex = RegExp(r'mailto:');

  const LinearTimeEmailLinkifier();

  @override
  List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options) =>
      _parseTextElements(elements, _parseText);

  void _parseText(String text, List<LinkifyElement> list) {
    var textStart = 0;
    for (final match in _localPartRunRegex.allMatches(text)) {
      if (match.group(2) == null) continue;
      final emailStart = _includeMailtoBeforeRun(text, textStart, match);
      _addText(list, text.substring(textStart, emailStart));
      final email = text.substring(emailStart, match.end);
      list.add(EmailElement(email.replaceFirst(_mailtoRegex, '')));
      textStart = match.end;
    }
    _addText(list, text.substring(textStart));
  }

  // The package also matches a "mailto:" that ends a previous run, e.g. "xmailto:a@b.cc".
  int _includeMailtoBeforeRun(String text, int textStart, RegExpMatch match) {
    final mailtoStart = match.start - _mailtoPrefix.length;
    final hasMailtoBefore = match.group(1) == null &&
        mailtoStart >= textStart &&
        text.substring(mailtoStart, match.start).toLowerCase() == _mailtoPrefix;
    return hasMailtoBefore ? mailtoStart : match.start;
  }
}

/// Same output as [UrlLinkifier], in linear time.
///
/// The package re-anchors and copies the remaining text after every match,
/// which is quadratic in the number of links. Here a single `allMatches`
/// pass finds the same leftmost matches.
class LinearTimeUrlLinkifier extends Linkifier {
  static final _urlRegex = RegExp(
    r'(?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*',
    caseSensitive: false,
    dotAll: true,
  );
  static final _looseUrlRegex = RegExp(
    r'''(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//="'`]*)''',
    caseSensitive: false,
    dotAll: true,
  );
  static final _protocolIdentifierRegex = RegExp(r'^(https?:\/\/)', caseSensitive: false);
  static final _httpSchemeRegex = RegExp(r'https?://');
  static final _wwwRegex = RegExp(r'www\.');

  const LinearTimeUrlLinkifier();

  @override
  List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options) {
    final regex = options.looseUrl ? _looseUrlRegex : _urlRegex;
    return _parseTextElements(
      elements,
      (text, list) => _parseText(text, regex, options, list),
    );
  }

  void _parseText(String text, RegExp regex, LinkifyOptions options, List<LinkifyElement> list) {
    var textStart = 0;
    for (final match in regex.allMatches(text)) {
      _addText(list, text.substring(textStart, match.start));
      _addUrl(list, match.group(0)!, options);
      textStart = match.end;
    }
    _addText(list, text.substring(textStart));
  }

  void _addUrl(List<LinkifyElement> list, String matchedUrl, LinkifyOptions options) {
    final excludesLastPeriod = options.excludeLastPeriod && matchedUrl.endsWith('.');
    final originText = excludesLastPeriod
        ? matchedUrl.substring(0, matchedUrl.length - 1)
        : matchedUrl;
    final href = originText.startsWith(_protocolIdentifierRegex)
        ? originText
        : (options.defaultToHttps ? 'https://' : 'http://') + originText;

    if (options.humanize || options.removeWww) {
      var displayText = originText;
      if (options.humanize) {
        displayText = displayText.replaceFirst(_httpSchemeRegex, '');
      }
      if (options.removeWww) {
        displayText = displayText.replaceFirst(_wwwRegex, '');
      }
      list.add(UrlElement(href, displayText, originText));
    } else {
      list.add(UrlElement(href, null, originText));
    }

    if (excludesLastPeriod) list.add(TextElement('.'));
  }
}

typedef _TextParser = void Function(String text, List<LinkifyElement> list);

List<LinkifyElement> _parseTextElements(List<LinkifyElement> elements, _TextParser parseText) {
  final list = <LinkifyElement>[];
  for (final element in elements) {
    if (element is TextElement) {
      parseText(element.text, list);
    } else {
      list.add(element);
    }
  }
  return list;
}

void _addText(List<LinkifyElement> list, String text) {
  if (text.isNotEmpty) list.add(TextElement(text));
}
