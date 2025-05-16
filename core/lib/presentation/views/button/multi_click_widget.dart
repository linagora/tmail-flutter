import 'package:flutter/material.dart';

import '../../../utils/app_logger.dart';

class MultiClickWidget extends StatefulWidget {
  final Widget child;
  final int requiredClicks;
  final Duration interval;
  final VoidCallback onMultiTap;

  const MultiClickWidget({
    Key? key,
    required this.child,
    required this.onMultiTap,
    this.requiredClicks = 7,
    this.interval = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<MultiClickWidget> createState() => _MultiClickWidgetState();
}

class _MultiClickWidgetState extends State<MultiClickWidget> {
  int _clickCount = 0;
  DateTime? _lastClickTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) > widget.interval) {
      _clickCount = 1;
    } else {
      _clickCount++;
    }

    _lastClickTime = now;
    log('_MultiClickWidgetState::_handleTap: ClickCount: $_clickCount');
    if (_clickCount >= widget.requiredClicks) {
      _clickCount = 0;
      widget.onMultiTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
