import 'package:flutter/material.dart';

class SuggestionsBoxController {
  final BuildContext context;

  OverlayEntry? overlayEntry;

  bool _isOpened = false;

  bool get isOpened => _isOpened;

  SuggestionsBoxController(this.context);

  void open() {
    if (_isOpened) return;
    assert(overlayEntry != null);
    Overlay.of(context)?.insert(overlayEntry!);
    _isOpened = true;
  }

  void close() {
    if (!_isOpened) return;
    assert(overlayEntry != null);
    overlayEntry!.remove();
    _isOpened = false;
  }

  void toggle() {
    if (_isOpened) {
      close();
    } else {
      open();
    }
  }
}
