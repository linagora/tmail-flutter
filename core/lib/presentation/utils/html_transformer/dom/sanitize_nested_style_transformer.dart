import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';
// The CSS sanitizer of our sanitize_html fork is not exported publicly.
// ignore: implementation_imports
import 'package:sanitize_html/src/css_sanitizer.dart';

/// Stylesheets containing nested blocks (`@media`, `@supports`,
/// `@keyframes`, ...) only go through a token blocklist in the HTML
/// sanitizer: they keep arbitrary properties and remote `url()` references
/// (read tracking, CSS exfiltration, UI redressing).
///
/// This transformer runs after the sanitizer and applies the same
/// property allow-list and `url()` validation as for flat stylesheets:
/// - `@media` blocks are kept, with their rules sanitized,
/// - every other at-rule is dropped,
/// - plain rules are sanitized.
class SanitizeNestedStyleTransformer extends DomTransformer {

  const SanitizeNestedStyleTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      for (final element in document.querySelectorAll('style')) {
        final css = element.text;
        if (!_containsNestedBlock(css)) continue;

        final sanitized = sanitizeNestedStylesheet(css);
        if (sanitized.isEmpty) {
          element.remove();
        } else {
          element.text = sanitized;
        }
      }
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
    }
  }

  static bool _containsNestedBlock(String css) {
    var depth = 0;
    for (var i = 0; i < css.length; i++) {
      final c = css.codeUnitAt(i);
      if (c == 0x7B /* { */) {
        depth++;
        if (depth > 1) return true;
      } else if (c == 0x7D /* } */ && depth > 0) {
        depth--;
      }
    }
    return false;
  }

  static String sanitizeNestedStylesheet(String css) {
    final buffer = StringBuffer();

    for (final block in _splitTopLevelBlocks(css)) {
      final prelude = block.prelude;

      if (prelude.startsWith('@')) {
        if (!prelude.toLowerCase().startsWith('@media')) continue;

        final inner = CssSanitizer.sanitizeStylesheet(block.body);
        if (inner.isEmpty) continue;

        buffer
          ..write(prelude)
          ..write(' { ')
          ..write(inner)
          ..writeln(' }');
      } else {
        final rule = CssSanitizer.sanitizeStylesheet('$prelude { ${block.body} }');
        if (rule.isNotEmpty) buffer.writeln(rule);
      }
    }

    return buffer.toString().trim();
  }

  /// Splits a stylesheet into top-level `prelude { body }` blocks, tracking
  /// brace depth so that nested blocks stay inside their parent's body.
  /// Unbalanced trailing content is dropped.
  static List<({String prelude, String body})> _splitTopLevelBlocks(String css) {
    final blocks = <({String prelude, String body})>[];
    var depth = 0;
    var preludeStart = 0;
    var bodyStart = 0;
    String? prelude;

    for (var i = 0; i < css.length; i++) {
      final c = css.codeUnitAt(i);
      if (c == 0x7B /* { */) {
        if (depth == 0) {
          prelude = css.substring(preludeStart, i).trim();
          bodyStart = i + 1;
        }
        depth++;
      } else if (c == 0x7D /* } */) {
        if (depth == 0) {
          preludeStart = i + 1;
          continue;
        }
        depth--;
        if (depth == 0) {
          if (prelude != null && prelude.isNotEmpty) {
            blocks.add((prelude: prelude, body: css.substring(bodyStart, i)));
          }
          prelude = null;
          preludeStart = i + 1;
        }
      } else if (c == 0x3B /* ; */ && depth == 0) {
        // Statement at-rules such as @import / @charset: skip them.
        preludeStart = i + 1;
      }
    }

    return blocks;
  }
}
