import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef OnHoverShowSubmenu = void Function(GlobalKey key);

class HoverSubmenuController {
  HoverSubmenuController({
    this.exitDelay = const Duration(milliseconds: 120),
  });

  final Duration exitDelay;

  final ValueNotifier<bool> isHovering = ValueNotifier(false);

  int _hoverRefCount = 0;
  Timer? _exitTimer;

  void enter() {
    _exitTimer?.cancel();
    _hoverRefCount++;
    if (!isHovering.value) {
      isHovering.value = true;
    }
  }

  void exit() {
    _hoverRefCount = (_hoverRefCount - 1).clamp(0, 999);

    if (_hoverRefCount == 0) {
      _exitTimer?.cancel();
      _exitTimer = Timer(exitDelay, () {
        if (_hoverRefCount == 0) {
          isHovering.value = false;
        }
      });
    }
  }

  void dispose() {
    _exitTimer?.cancel();
    isHovering.dispose();
  }
}
