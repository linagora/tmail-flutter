import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SubmenuDirection { left, right, auto }

class PopupSubmenuController {
  OverlayEntry? _submenuEntry;

  bool get isShowing => _submenuEntry != null;

  void show({
    required BuildContext context,
    required Rect anchor,
    required Widget submenu,
    SubmenuDirection direction = SubmenuDirection.auto,
    double submenuWidth = 249,
    double submenuMaxHeight = 400,
    double offset = 0,
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

    final clampedLeft = finalLeft
        .clamp(0.0, math.max(0.0, screenWidth - submenuWidth))
        .toDouble();
    final availableHeight = math.max(0.0, screenHeight - anchor.top);
    final finalHeight = math.min(submenuMaxHeight, availableHeight);

    _submenuEntry = OverlayEntry(
      builder: (_) {
        return PositionedDirectional(
          start: clampedLeft,
          top: anchor.top,
          child: MouseRegion(
            onExit: (_) => hide(),
            child: Material(
              elevation: 8,
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: SizedBox(
                width: submenuWidth,
                height: finalHeight,
                child: submenu,
              ),
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
