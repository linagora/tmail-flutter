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

    final screenWidth = MediaQuery.of(context).size.width;

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

    _submenuEntry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: finalLeft,
          top: anchor.top,
          child: MouseRegion(
            onExit: (_) => hide(),
            child: Material(
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: SizedBox(
                width: submenuWidth,
                height: submenuMaxHeight,
                child: submenu,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_submenuEntry!);
  }

  void hide() {
    _submenuEntry?.remove();
    _submenuEntry = null;
  }

  void dispose() {
    hide();
  }
}
