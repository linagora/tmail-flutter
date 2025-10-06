import 'package:flutter/material.dart';

extension ScrollControllerExtension on ScrollController {
  void scrollToWidgetTop({
    required GlobalKey key,
    double padding = 70,
  }) {
    final context = key.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return;

    final offsetY = renderBox.localToGlobal(Offset.zero).dy;
    final currentScroll = offset;

    final targetOffset = (currentScroll + offsetY - padding).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

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
