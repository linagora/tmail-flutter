
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/linear_time_linkifiers.dart';
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
    const LinearTimeEmailLinkifier(),
    const LinearTimeUrlLinkifier(),
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
    final rebuiltChildren = <Node>[];
    var hasLinkifiedText = false;
    for (final child in node.nodes.toList()) {
      final replacements = child is Text ? _linkifyTextNode(child) : null;
      if (replacements != null) {
        rebuiltChildren.addAll(replacements);
        hasLinkifiedText = true;
        continue;
      }
      if (child is Element &&
          !_skipTags.contains(child.localName?.toLowerCase())) {
        _linkifyNode(child);
      }
      rebuiltChildren.add(child);
    }
    // Rebuild the child list once: splicing per text node rescans the siblings, quadratic on many links.
    if (hasLinkifiedText) {
      node.nodes
        ..clear()
        ..addAll(rebuiltChildren);
    }
  }

  List<Node>? _linkifyTextNode(Text textNode) {
    final text = textNode.text;
    if (text.isEmpty) return null;

    final elements = linkify(text, options: _linkifyOption, linkifiers: _linkifiers);
    if (elements.every((e) => e is TextElement)) return null;

    return [
      for (final el in elements)
        if (el is TextElement)
          Text(el.text)
        else if (el is UrlElement)
          _buildUrlAnchor(el.url, el.text)
        else if (el is EmailElement)
          _buildEmailAnchor(el.url, el.text),
    ];
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
