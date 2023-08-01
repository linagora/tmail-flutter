
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:linkify/linkify.dart';

class SanitizeAutolinkFilter {

  final HtmlEscape htmlEscape;
  final _linkifyOption = const LinkifyOptions(
    humanize: true,
    looseUrl: true,
    defaultToHttps: true,
    removeWww: true
  );
  final _linkifier = <Linkifier>[
    const EmailLinkifier(),
    const UrlLinkifier()
  ];

  SanitizeAutolinkFilter(this.htmlEscape);

  String process(String inputText) {
    if (inputText.isEmpty) {
      return '';
    }

    final elements = linkify(
      inputText,
      options: _linkifyOption,
      linkifiers: _linkifier
    );
    log('AutolinkFilter::process:elements: $elements');
    final htmlTextBuffer = StringBuffer();

    for (var element in elements) {
      if (element is TextElement) {
        final escapedHtml = htmlEscape.convert(element.text);
        htmlTextBuffer.write(escapedHtml);
      } else if (element is EmailElement) {
        final emailLinkTag = _buildEmailLinkTag(
          mailToLink: element.url,
          value: element.text
        );
        htmlTextBuffer.write(emailLinkTag);
      } else if (element is UrlElement) {
        final urlLinkTag = _buildUrlLinkTag(
          urlLink: element.url,
          value: element.text
        );
        htmlTextBuffer.write(urlLinkTag);
      }
    }

    return htmlTextBuffer.toString();
  }

  String _buildUrlLinkTag({required String urlLink, required String value}) {
    return '<a href="$urlLink" target="_blank" rel="noreferrer">$value</a>';
  }

  String _buildEmailLinkTag({required String mailToLink, required String value}) {
    return '<a href="$mailToLink">$value</a>';
  }
}