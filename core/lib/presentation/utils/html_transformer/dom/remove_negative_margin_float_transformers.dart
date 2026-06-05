import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart' show visibleForTesting;
import 'package:html/dom.dart';

/// Removes inline CSS patterns that clip the left edge of email content
/// rendered in a body with `overflow-x: hidden`.
///
/// **Case 1 — float + same-side negative margin**
/// GitLab heading anchors carry `float: left; margin-left: -20px` for gutter
/// deep-links. `overflow-x: hidden` creates a BFC (Block Formatting Context)
/// whose scroll extent expands leftward to contain the float; because scrolling
/// is suppressed, the first N px of content are clipped.
///
/// **Case 2 — aria-hidden anchor with negative margin (post-sanitisation)**
/// The CSS sanitiser strips `float` (not in `allowedCssProperties`), turning
/// the anchor into an inline element whose `margin-left: -Npx` shifts sibling
/// heading text into the clipped zone. `aria-hidden="true"` anchors are purely
/// decorative, so removing their negative margin has no visual impact.
class RemoveNegativeMarginFloatTransformer extends DomTransformer {
  const RemoveNegativeMarginFloatTransformer();

  // \s* around `:` tolerates irregular spacing (e.g. `float : left ;`).
  static final _floatLeftPattern = RegExp(
    r'float\s*:\s*left\s*;?',
    caseSensitive: false,
  );
  static final _floatRightPattern = RegExp(
    r'float\s*:\s*right\s*;?',
    caseSensitive: false,
  );

  // [^;]+ captures the value and unit without crossing a property boundary;
  // `;?` handles the last property, which may omit the trailing semicolon.
  static final _negativeMarginLeftPattern = RegExp(
    r'margin-left\s*:\s*-[^;]+;?',
    caseSensitive: false,
  );
  static final _negativeMarginRightPattern = RegExp(
    r'margin-right\s*:\s*-[^;]+;?',
    caseSensitive: false,
  );

  static final _multipleSpacesPattern = RegExp(r' {2,}');

  @visibleForTesting
  static RegExp get floatLeftPattern => _floatLeftPattern;

  @visibleForTesting
  static RegExp get floatRightPattern => _floatRightPattern;

  @visibleForTesting
  static RegExp get negativeMarginLeftPattern => _negativeMarginLeftPattern;

  @visibleForTesting
  static RegExp get negativeMarginRightPattern => _negativeMarginRightPattern;

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      // Narrow selector: only float-bearing elements and aria-hidden anchors
      // are candidates — avoids scanning every styled element in the document.
      final elements = document.querySelectorAll(
        '[style*="float"], a[aria-hidden="true"][style]',
      );
      for (final element in elements) {
        final style = element.attributes['style'];
        if (style == null) continue;

        var updatedStyle = style;

        // Case 1: float + same-side negative margin.
        // In production, the CSS sanitiser strips float before DOM transformers
        // run (Case 2 handles that path). This is a defensive guard for raw
        // HTML and any future allowedCssProperties changes that re-allow float.
        if (_floatLeftPattern.hasMatch(style) && _negativeMarginLeftPattern.hasMatch(style)) {
          updatedStyle = updatedStyle
              .replaceAll(_floatLeftPattern, '')
              .replaceAll(_negativeMarginLeftPattern, '');
        }
        if (_floatRightPattern.hasMatch(style) && _negativeMarginRightPattern.hasMatch(style)) {
          updatedStyle = updatedStyle
              .replaceAll(_floatRightPattern, '')
              .replaceAll(_negativeMarginRightPattern, '');
        }

        // Case 2: aria-hidden anchor with negative margin (the common path).
        // The sanitiser strips float but preserves margin-left, so the anchor
        // becomes inline with a negative margin that shifts heading text into
        // the clipped zone. Operate on updatedStyle so Case 1 removals are reflected.
        final isAriaHiddenAnchor = element.localName == 'a' &&
            element.attributes['aria-hidden'] == 'true';
        if (isAriaHiddenAnchor) {
          if (_negativeMarginLeftPattern.hasMatch(updatedStyle)) {
            updatedStyle = updatedStyle.replaceAll(_negativeMarginLeftPattern, '');
          }
          if (_negativeMarginRightPattern.hasMatch(updatedStyle)) {
            updatedStyle = updatedStyle.replaceAll(_negativeMarginRightPattern, '');
          }
        }

        if (updatedStyle == style) continue;

        updatedStyle = updatedStyle
            .replaceAll(_multipleSpacesPattern, ' ')
            .trim();

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
}
