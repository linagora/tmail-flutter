import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart' show visibleForTesting;
import 'package:html/dom.dart';

/// Strips `line-height` values small enough to overlap text lines (e.g. some
/// signatures ship `line-height:0.1`), letting the renderer fall back to its
/// default leading. Removed rather than clamped, matching correct clients.
/// `line-height:0` is left untouched: it is the intentional image-gap/spacer
/// trick, not an overlap bug.
class NormalizeLineHeightInStyleTransformer extends DomTransformer {
  const NormalizeLineHeightInStyleTransformer();

  // Removal bounds. Major mail clients (Gmail, Outlook, Apple Mail) never
  // rewrite `line-height`, so intervene as narrowly as possible — two classes
  // of removal only:
  //  - Degenerate: element-relative values small enough to visibly overlap
  //    text lines (< 0.8× font-size; the UA default is ~1.2×). Values in
  //    [0.8, 1) such as `90%`/`0.9em` are tight-but-legitimate typography and
  //    are preserved for fidelity — especially since reply/draft pipelines
  //    save and send the transformed style.
  //  - TF-3964 legacy: exactly `100%` (and `1em`, the same computed length),
  //    plus absolute values up to `1px`/`1pt`. These shipped as removals and
  //    must not silently come back.
  //  `rem` is root-relative, so overlap cannot be judged from the number
  //  alone (`0.9rem` ≈ 14.4px is fine leading for 12px text) — never removed.
  static const _degenerateRatioBound = 0.8; // unitless & em, exclusive
  static const _degeneratePercentBound = 80.0; // %, exclusive
  static const _legacyRatio = 1.0; // TF-3964: `1em` ≡ `100%`
  static const _legacyPercent = 100.0; // TF-3964
  static const _absoluteRemovalThreshold = 1.0; // px / pt, inclusive

  /// A CSS number + optional unit. `!important` is stripped beforehand by
  /// [_stripImportant], so the pattern needs no whitespace: keywords,
  /// `calc(...)`, negatives, and >9-digit values simply do not match and are
  /// kept. No whitespace + bounded `\d{1,9}` + `^` anchor make matching
  /// constant-work — ReDoS-safe (ADR 0069-redos-vulnerability-mitigation).
  static final _numericValuePattern = RegExp(
    r'^\+?(\d{1,9}(?:\.\d{0,9})?|\.\d{1,9})(px|pt|em|rem|%)?$',
    caseSensitive: false,
  );

  @visibleForTesting
  static RegExp get numericValuePattern => _numericValuePattern;

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      // `[style*=...]` is case-sensitive and would miss `LINE-HEIGHT`; select
      // all styles and filter case-insensitively.
      final elements = document.querySelectorAll('[style]');

      for (final element in elements) {
        final originalStyle = element.attributes['style'];
        if (originalStyle == null) continue;
        if (!originalStyle.toLowerCase().contains('line-height')) continue;

        final updatedStyle = _stripDegenerateLineHeights(originalStyle);
        if (updatedStyle == null) continue; // unchanged or malformed → keep

        if (updatedStyle.isEmpty) {
          element.attributes.remove('style');
        } else {
          element.attributes['style'] = updatedStyle;
        }
      }
    } catch (e) {
      logWarning('$runtimeType::process: Exception = $e');
    }
  }

  /// Returns [style] with degenerate `line-height` declarations removed, or
  /// `null` when nothing changed or the CSS is malformed (fail-open: keep the
  /// original). Kept declarations are re-emitted verbatim.
  String? _stripDegenerateLineHeights(String style) {
    final declarations = _splitTopLevelDeclarations(style);
    if (declarations == null) return null; // malformed → fail-open

    var removed = false;
    final kept = StringBuffer();
    for (final declaration in declarations) {
      if (_isRemovableLineHeight(declaration)) {
        removed = true;
      } else {
        kept.write(declaration);
      }
    }
    return removed ? kept.toString().trim() : null;
  }

  /// Splits [style] at top-level `;`, ignoring semicolons inside quotes,
  /// comments, or parentheses, and honoring CSS `\` escapes. Each declaration
  /// keeps its original text (including any trailing `;`). Returns `null` for
  /// malformed CSS (unterminated quote/comment, unbalanced parenthesis, or a
  /// trailing backslash). Single linear scan — no backtracking, so ReDoS-immune
  /// (ADR 0069-redos-vulnerability-mitigation).
  List<String>? _splitTopLevelDeclarations(String style) {
    final declarations = <String>[];
    var start = 0;
    var inSingleQuote = false;
    var inDoubleQuote = false;
    var inComment = false;
    var parenDepth = 0;

    for (var i = 0; i < style.length; i++) {
      final char = style[i];
      final next = i + 1 < style.length ? style[i + 1] : '';

      if (inComment) {
        if (char == '*' && next == '/') {
          inComment = false;
          i++;
        }
      } else if (inSingleQuote) {
        if (char == '\\') {
          i++; // skip the escaped character
        } else if (char == "'") {
          inSingleQuote = false;
        }
      } else if (inDoubleQuote) {
        if (char == '\\') {
          i++;
        } else if (char == '"') {
          inDoubleQuote = false;
        }
      } else if (char == '\\') {
        if (next.isEmpty) return null; // trailing backslash → fail-open
        i++; // escaped char is literal data (e.g. `\;`), never a boundary
      } else if (char == '/' && next == '*' && parenDepth == 0) {
        // Inside parentheses `/*` is data, not a comment — an unquoted
        // `url(https://x/a/*/b.png)` must not poison the whole attribute
        // (fail-open would keep a degenerate line-height → TF-3964 returns).
        inComment = true;
        i++;
      } else if (char == "'") {
        inSingleQuote = true;
      } else if (char == '"') {
        inDoubleQuote = true;
      } else if (char == '(') {
        parenDepth++;
      } else if (char == ')') {
        if (parenDepth == 0) return null; // unbalanced
        parenDepth--;
      } else if (char == ';' && parenDepth == 0) {
        declarations.add(style.substring(start, i + 1));
        start = i + 1;
      }
    }

    if (inSingleQuote || inDoubleQuote || inComment || parenDepth != 0) {
      return null; // unterminated
    }
    if (start < style.length) declarations.add(style.substring(start));
    return declarations;
  }

  bool _isRemovableLineHeight(String declaration) {
    final body = declaration.endsWith(';')
        ? declaration.substring(0, declaration.length - 1)
        : declaration;
    final colon = body.indexOf(':');
    if (colon == -1) return false;
    if (body.substring(0, colon).trim().toLowerCase() != 'line-height') {
      return false;
    }
    return _isDegenerateLineHeight(body.substring(colon + 1).trim());
  }

  /// Removes a trailing `!important` and any surrounding whitespace so the
  /// numeric pattern needs no whitespace quantifiers. Linear string ops (no
  /// backtracking), so every valid CSS spacing is handled without a magic bound.
  String _stripImportant(String value) {
    const keyword = 'important';
    if (value.length < keyword.length) return value;
    if (value.substring(value.length - keyword.length).toLowerCase() != keyword) {
      return value;
    }
    final beforeKeyword =
        value.substring(0, value.length - keyword.length).trimRight();
    if (!beforeKeyword.endsWith('!')) return value;
    return beforeKeyword.substring(0, beforeKeyword.length - 1).trimRight();
  }

  bool _isDegenerateLineHeight(String value) {
    final match = _numericValuePattern.firstMatch(_stripImportant(value));
    if (match == null) return false;

    final number = double.tryParse(match.group(1) ?? '');
    if (number == null || !number.isFinite) return false;

    // `line-height:0` (any unit) is the intentional image-gap/spacer trick used
    // to collapse whitespace around images; preserve it. Only strip the small
    // non-zero values that overlap text.
    if (number <= 0) return false;

    switch (match.group(2)?.toLowerCase()) {
      case '%':
        return number < _degeneratePercentBound || number == _legacyPercent;
      case 'em':
        return number < _degenerateRatioBound || number == _legacyRatio;
      case 'rem':
        return false; // root-relative: overlap cannot be judged from the number
      case 'px':
      case 'pt':
        return number <= _absoluteRemovalThreshold;
      default: // unitless multiplier
        return number < _degenerateRatioBound;
    }
  }
}
