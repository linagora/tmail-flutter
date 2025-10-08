import 'package:flutter/material.dart';

class MiddleEllipsisText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// Ratio of characters to keep at the start (0–1). Default = 0.5
  final double keepStartFraction;

  const MiddleEllipsisText(
    this.text, {
    super.key,
    this.style,
    this.keepStartFraction = 0.5,
  });

  @override
  State<MiddleEllipsisText> createState() => _MiddleEllipsisTextState();
}

class _MiddleEllipsisTextState extends State<MiddleEllipsisText> {
  // Cache fields
  String? _cachedText;
  String? _cachedStyleKey;
  double? _cachedWidth;
  String? _cachedResult;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final styleKey = _styleKey(style);
    final textDir = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // Use cached result if nothing changed
        if (_cachedText == widget.text &&
            _cachedStyleKey == styleKey &&
            _cachedWidth == maxWidth) {
          return Text(
            _cachedResult!,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.visible,
          );
        }

        final truncated = _truncateMiddleByWidth(
          widget.text,
          maxWidth,
          style,
          textDir: textDir,
          keepStartFraction: widget.keepStartFraction,
        );

        // Update cache
        _cachedText = widget.text;
        _cachedStyleKey = styleKey;
        _cachedWidth = maxWidth;
        _cachedResult = truncated;

        return Text(
          truncated,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.visible,
        );
      },
    );
  }

  String _truncateMiddleByWidth(
    String text,
    double maxWidth,
    TextStyle style, {
    required TextDirection textDir,
    double keepStartFraction = 0.5,
  }) {
    final painter = TextPainter(
      textDirection: textDir,
      maxLines: 1,
    );

    // Measure full text
    painter.text = TextSpan(text: text, style: style);
    painter.layout(maxWidth: double.infinity);
    if (painter.width <= maxWidth) return text;

    // Measure ellipsis width
    const ellipsis = '...';
    painter.text = TextSpan(text: ellipsis, style: style);
    painter.layout(maxWidth: double.infinity);
    final ellipsisWidth = painter.width;

    if (maxWidth <= ellipsisWidth) return ellipsis;

    // Binary search for best prefix+suffix length
    int lo = 0, hi = text.length;
    String best = ellipsis;

    final f = keepStartFraction.clamp(0.0, 1.0);

    double measure(String t) {
      painter.text = TextSpan(text: t, style: style);
      painter.layout(maxWidth: double.infinity);
      return painter.width;
    }

    while (lo <= hi) {
      final k = (lo + hi) ~/ 2;
      int leftLen = (k * f).round().clamp(0, text.length);
      int rightLen = (k - leftLen).clamp(0, text.length - leftLen);

      final candidate = text.substring(0, leftLen) +
          ellipsis +
          text.substring(text.length - rightLen);
      final width = measure(candidate);

      if (width <= maxWidth) {
        best = candidate;
        lo = k + 1;
      } else {
        hi = k - 1;
      }
    }

    return best;
  }

  // Cache key based on style properties
  String _styleKey(TextStyle s) =>
      '${s.fontFamily}|${s.fontSize}|${s.fontWeight}|${s.fontStyle}|${s.letterSpacing}|${s.wordSpacing}|${s.height}';
}
