
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:linkify/linkify.dart';

class SanitizeAutolinkFilter {

  final HtmlEscape htmlEscape;
  final bool escapeHtml;

  // Static to avoid re-allocating per instance — SanitizeAutolinkFilter is
  // instantiated on every transform call from the transformer wrappers.
  static const _linkifyOption = LinkifyOptions(
    humanize: true,
    looseUrl: true,
    defaultToHttps: true,
    removeWww: true,
  );
  static final _linkifier = <Linkifier>[
    const EmailLinkifier(),
    const UrlLinkifier(),
  ];

  // Matches a complete HTML tag, correctly handling quoted attribute values
  // that may contain the > character (e.g. title="a > b").
  static final _htmlTagPattern = RegExp(r'''<(?:[^>"']*|"[^"]*"|'[^']*')*>''');

  SanitizeAutolinkFilter(this.htmlEscape, {this.escapeHtml = true});

  String process(String inputText) {
    try {
      if (inputText.isEmpty) return '';

      final result = escapeHtml
          ? _linkifyText(inputText)
          : _linkifyHtmlAware(inputText);

      log('SanitizeAutolinkFilter::process:htmlTextBuffer = $result');
      return result;
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
      return inputText;
    }
  }

  // Linkifies only text nodes between HTML tags, leaving existing tags intact.
  // This prevents re-linkifying URLs that already appear inside href/src attributes,
  // which would produce broken HTML like href="<a href="...">".
  String _linkifyHtmlAware(String inputText) {
    final buffer = StringBuffer();
    int cursor = 0;

    for (final tagMatch in _htmlTagPattern.allMatches(inputText)) {
      if (tagMatch.start > cursor) {
        buffer.write(_linkifyText(inputText.substring(cursor, tagMatch.start)));
      }
      buffer.write(tagMatch.group(0));
      cursor = tagMatch.end;
    }

    if (cursor < inputText.length) {
      buffer.write(_linkifyText(inputText.substring(cursor)));
    }

    return buffer.toString();
  }

  String _linkifyText(String text) {
    final elements = linkify(text, options: _linkifyOption, linkifiers: _linkifier);
    final buffer = StringBuffer();

    for (final element in elements) {
      if (element is TextElement) {
        buffer.write(escapeHtml ? htmlEscape.convert(element.text) : element.text);
      } else if (element is EmailElement) {
        buffer.write(_buildEmailLinkTag(mailToLink: element.url, value: element.text));
      } else if (element is UrlElement) {
        buffer.write(_buildUrlLinkTag(urlLink: element.url, value: element.text));
      }
    }

    return buffer.toString();
  }

  String _buildUrlLinkTag({required String urlLink, required String value}) {
    return '<a href="$urlLink" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">$value</a>';
  }

  String _buildEmailLinkTag({required String mailToLink, required String value}) {
    return '<a href="$mailToLink" style="white-space: nowrap; word-break: keep-all;">$value</a>';
  }
}