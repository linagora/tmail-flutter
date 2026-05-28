
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';
import 'package:linkify/linkify.dart';

/// Linkifies bare URLs and email addresses found in DOM text nodes.
///
/// Unlike a regex-based text transformer, this walks the already-parsed DOM so
/// HTML tag boundaries are derived from the document structure — no regex is
/// needed to detect them, and there is no ReDoS risk.
///
/// Skips text inside [_skipTags] elements (e.g. existing <a>, <script>,
/// <style>) to avoid double-linkifying or injecting links into unsafe contexts.
class AutolinkTextNodeTransformer extends DomTransformer {
  static const _linkifyOption = LinkifyOptions(
    humanize: true,
    looseUrl: true,
    defaultToHttps: true,
    removeWww: true,
  );
  static final _linkifiers = <Linkifier>[
    const EmailLinkifier(),
    const UrlLinkifier(),
  ];
  static const _skipTags = {'a', 'script', 'style', 'textarea'};

  const AutolinkTextNodeTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      if (document.body == null) return;
      _linkifyNode(document.body!);
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
    }
  }

  void _linkifyNode(Node node) {
    for (final child in node.nodes.toList()) {
      if (child is Text) {
        _linkifyTextNode(child);
      } else if (child is Element &&
          !_skipTags.contains(child.localName?.toLowerCase())) {
        _linkifyNode(child);
      }
    }
  }

  void _linkifyTextNode(Text textNode) {
    final text = textNode.text;
    if (text.isEmpty) return;

    final elements = linkify(text, options: _linkifyOption, linkifiers: _linkifiers);
    if (elements.every((e) => e is TextElement)) return;

    final parent = textNode.parentNode;
    if (parent == null) return;

    for (final el in elements) {
      if (el is TextElement) {
        parent.insertBefore(Text(el.text), textNode);
      } else if (el is UrlElement) {
        parent.insertBefore(_buildUrlAnchor(el.url, el.text), textNode);
      } else if (el is EmailElement) {
        parent.insertBefore(_buildEmailAnchor(el.url, el.text), textNode);
      }
    }
    textNode.remove();
  }

  Element _buildUrlAnchor(String href, String text) => Element.tag('a')
    ..attributes['href'] = href
    ..attributes['target'] = '_blank'
    ..attributes['rel'] = 'noreferrer'
    ..attributes['style'] = 'white-space: nowrap; word-break: keep-all;'
    ..append(Text(text));

  Element _buildEmailAnchor(String href, String text) => Element.tag('a')
    ..attributes['href'] = href
    ..attributes['style'] = 'white-space: nowrap; word-break: keep-all;'
    ..append(Text(text));
}
