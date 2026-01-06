import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SubmenuDirection { left, right, auto }

class ContextSubmenuController {
  OverlayEntry? _submenuEntry;

  bool get isShowing => _submenuEntry != null;

  void show({
    required BuildContext context,
    required Rect anchor,
    required Rect anchorMenu,
    required Widget submenu,
    SubmenuDirection direction = SubmenuDirection.auto,
    double submenuWidth = 191,
    double submenuMaxHeight = 352,
    double offset = 4,
    double menuFieldSpacing = 8,
  }) {
    hide();

    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    final mediaSize = MediaQuery.sizeOf(context);
    final screenWidth = mediaSize.width;
    final screenHeight = mediaSize.height;

    final rightPosition = anchor.right + offset;
    final leftPosition = anchor.left - submenuWidth - offset;

    bool canShowRight = rightPosition + submenuWidth <= screenWidth;
    bool canShowLeft = leftPosition >= 0;

    double? finalLeft;

    if (direction == SubmenuDirection.right) {
      finalLeft = rightPosition;
    } else if (direction == SubmenuDirection.left) {
      finalLeft = leftPosition;
    } else {
      if (canShowRight) {
        finalLeft = rightPosition;
      } else if (canShowLeft) {
        finalLeft = leftPosition;
      } else {
        finalLeft = rightPosition;
      }
    }

    final bottom = screenHeight - anchorMenu.bottom + menuFieldSpacing;

    final clampedLeft = finalLeft
        .clamp(0.0, math.max(0.0, screenWidth - submenuWidth))
        .toDouble();
    final availableHeight = math.max(0.0, screenHeight - anchor.top);
    final finalHeight = math.min(submenuMaxHeight, availableHeight);

    _submenuEntry = OverlayEntry(
      builder: (_) {
        return PositionedDirectional(
          start: clampedLeft,
          bottom: bottom,
          child: MouseRegion(
            onExit: (_) => hide(),
            child: Container(
              width: submenuWidth,
              constraints: BoxConstraints(maxHeight: finalHeight),
              child: submenu,
            ),
          ),
        );
      },
    );

    overlayState.insert(_submenuEntry!);
  }

  void hide() {
    _submenuEntry?.remove();
    _submenuEntry = null;
  }

  void dispose() {
    hide();
  }
}
