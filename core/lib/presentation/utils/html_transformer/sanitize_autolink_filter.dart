
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:core/presentation/utils/html_transformer/linear_time_linkifiers.dart';
import 'package:linkify/linkify.dart';

class SanitizeAutolinkFilter {

  final HtmlEscape htmlEscape;

  // Static to avoid re-allocating per instance — SanitizeAutolinkFilter is
  // instantiated on every transform call from the transformer wrappers.
  static const _linkifyOption = LinkifyOptions(
    humanize: true,
    looseUrl: true,
    defaultToHttps: true,
    removeWww: true,
  );
  static final _linkifier = <Linkifier>[
    const LinearTimeEmailLinkifier(),
    const LinearTimeUrlLinkifier(),
  ];

  // The href is always double-quoted, so attribute mode is enough.
  static const _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  static const _quote = '"';

  SanitizeAutolinkFilter(this.htmlEscape);

  String process(String inputText) {
    try {
      if (inputText.isEmpty) return '';

      final result = _linkifyText(inputText);

      log('SanitizeAutolinkFilter::process:resultLength = ${result.length}');
      return result;
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
      return htmlEscape.convert(inputText);
    }
  }

  String _linkifyText(String text) {
    final elements = linkify(text, options: _linkifyOption, linkifiers: _linkifier);
    final buffer = StringBuffer();

    for (final element in elements) {
      if (element is TextElement) {
        buffer.write(htmlEscape.convert(element.text));
      } else if (element is EmailElement) {
        buffer.write(_buildEmailLinkTag(mailToLink: element.url, value: element.text));
      } else if (element is UrlElement) {
        _writeUrl(buffer, element);
      }
    }

    return buffer.toString();
  }

  // The loose URL pattern takes the closing quote of "https://…"; a lone trailing quote is never part of the URL.
  void _writeUrl(StringBuffer buffer, UrlElement element) {
    final origin = element.originText;
    final endsWithLoneQuote = origin.length > 1 &&
        origin.indexOf(_quote) == origin.length - 1 &&
        element.url.endsWith(_quote) &&
        element.text.endsWith(_quote);
    if (!endsWithLoneQuote) {
      buffer.write(_buildUrlLinkTag(urlLink: element.url, value: element.text));
      return;
    }
    buffer.write(_buildUrlLinkTag(
      urlLink: element.url.substring(0, element.url.length - 1),
      value: element.text.substring(0, element.text.length - 1),
    ));
    buffer.write(htmlEscape.convert(_quote));
  }

  String _buildUrlLinkTag({required String urlLink, required String value}) {
    final href = _attributeEscape.convert(urlLink);
    final text = htmlEscape.convert(value);
    return '<a href="$href" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">$text</a>';
  }

  String _buildEmailLinkTag({required String mailToLink, required String value}) {
    final href = _attributeEscape.convert(mailToLink);
    final text = htmlEscape.convert(value);
    return '<a href="$href" style="white-space: nowrap; word-break: keep-all;">$text</a>';
  }
}
