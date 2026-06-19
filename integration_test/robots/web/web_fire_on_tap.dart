import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fires the [TapGestureRecognizer] for the [TextSpan] whose text matches
/// [text] inside the first matching widget of [finder].
///
/// Required on web because [RichText] spans are not hit-testable via the
/// standard [WidgetTester.tap] — only the recognizer fire path works.
void webFireOnTap(Finder finder, String text) {
  final elements = finder.evaluate().toList();
  if (elements.isEmpty) {
    throw StateError('No widget found for tappable text: $text');
  }
  for (final element in elements) {
    final renderObject = element.renderObject;
    if (renderObject is RenderParagraph &&
        _tryFireTapInParagraph(renderObject, text)) {
      return;
    }
  }
  throw StateError('Tap target not found or not tappable: $text');
}

bool _tryFireTapInParagraph(RenderParagraph paragraph, String text) {
  var fired = false;
  paragraph.text.visitChildren((InlineSpan span) {
    if (span is! TextSpan || span.text != text) return true;
    final recognizer = span.recognizer;
    if (recognizer is TapGestureRecognizer) {
      recognizer.onTap?.call();
      fired = true;
      return false;
    }
    return true;
  });
  return fired;
}
