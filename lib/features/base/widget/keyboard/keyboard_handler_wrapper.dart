import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnHandleKeyEventAction = void Function(KeyEvent event);

class KeyboardHandlerWrapper extends StatelessWidget {
  final Widget child;
  final FocusNode focusNode;
  final OnHandleKeyEventAction onKeyDownEventAction;
  final OnHandleKeyEventAction? onKeyUpEventAction;

  const KeyboardHandlerWrapper({
    Key? key,
    required this.child,
    required this.focusNode,
    required this.onKeyDownEventAction,
    this.onKeyUpEventAction,
  }) : super(key: key);

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      onKeyDownEventAction(event);
    } else if (event is KeyUpEvent) {
      onKeyUpEventAction?.call(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: child,
    );
  }
}
