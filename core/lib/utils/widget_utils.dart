import 'package:flutter/material.dart';

class WidgetUtils {
  WidgetUtils._();

  static double measureTextWidth({
    required String text,
    double fallbackWidth = 0,
    TextStyle? style,
    Locale? locale,
    double? horizontalPadding,
  }) {
    try {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: style,
          locale: locale,
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (horizontalPadding != null) {
        return textPainter.width + horizontalPadding * 2;
      } else {
        return textPainter.width;
      }
    } catch (e) {
      return fallbackWidth;
    }
  }
}
