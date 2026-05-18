import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Defense-in-depth sanitizer for the HTML output of the plain-text pipeline.
///
/// By the time this runs, [SanitizeAutolinkHtmlTransformers] has already
/// HTML-escaped every text segment via [HtmlEscape.convert], so no injected
/// markup can survive as executable HTML. This transformer adds a second layer:
/// it only allows [<a>] tags with safe attributes; every other element is
/// unwrapped (children kept, tag removed), and comments are deleted.
///
/// This must run AFTER [SanitizeAutolinkHtmlTransformers], not before, because
/// running an HTML sanitizer on raw plain text produces false-positives (e.g.
/// the library's unicode-escape heuristic matches PHP namespace separators
/// like \Sabre\DAV and strips the entire text node).
class SanitizePlainTextHtmlOutputTransformer extends TextTransformer {
  // Scheme values as returned by Uri.scheme (no colon, always lowercase).
  static const _safeSchemes = {'http', 'https', 'mailto'};
  static const _safeAnchorAttributes = {'href', 'target', 'rel', 'style'};

  const SanitizePlainTextHtmlOutputTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) {
    if (text.isEmpty) return text;
    final body = html_parser.parse(text).body;
    if (body == null) return text;
    for (final child in body.nodes.toList()) {
      _sanitizeNode(child);
    }
    return body.innerHtml;
  }

  void _sanitizeNode(Node node) {
    if (node.nodeType == Node.COMMENT_NODE) {
      node.remove();
      return;
    }
    // Text nodes are already escaped — nothing to do.
    if (node is Text) return;
    if (node is! Element) {
      node.remove();
      return;
    }
    if (node.localName == 'a') {
      _sanitizeAnchor(node);
      for (final child in node.nodes.toList()) {
        _sanitizeNode(child);
      }
      return;
    }
    _unwrap(node);
  }

  // Replaces [element] with its children in the parent, then sanitizes each child.
  void _unwrap(Element element) {
    final parent = element.parent;
    if (parent == null) {
      element.remove();
      return;
    }
    final index = parent.nodes.indexOf(element);
    final children = element.nodes.toList();
    element.nodes.clear();
    parent.nodes
      ..removeAt(index)
      ..insertAll(index, children);
    for (final child in children) {
      _sanitizeNode(child);
    }
  }

  void _sanitizeAnchor(Element anchor) {
    final href = anchor.attributes['href'];
    final safe = href != null && _isSafeUrl(href);
    if (safe) {
      anchor.attributes.removeWhere(
        (key, _) =>
            !_safeAnchorAttributes.contains(key.toString().toLowerCase()),
      );
    } else {
      anchor.attributes.clear();
    }
  }

  bool _isSafeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    // Uri.scheme is always lowercase and excludes the colon.
    return uri != null && _safeSchemes.contains(uri.scheme);
  }
}
