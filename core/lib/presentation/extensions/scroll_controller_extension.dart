import 'package:flutter/material.dart';

extension ScrollControllerExtension on ScrollController {
  void scrollToBottomWithPadding({required double padding}) {
    try {
      final maxExtent = position.maxScrollExtent;

      final targetOffset = (maxExtent - padding).clamp(0.0, maxExtent);

      animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (_) {}
  }
}
