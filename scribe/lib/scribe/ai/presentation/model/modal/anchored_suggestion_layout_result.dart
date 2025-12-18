import 'package:flutter/cupertino.dart';

class AnchoredSuggestionLayoutResult {
  final Offset offset;
  final double availableHeight;
  final double? top;
  final double? bottom;

  const AnchoredSuggestionLayoutResult({
    required this.offset,
    required this.availableHeight,
    this.top,
    this.bottom,
  });
}
