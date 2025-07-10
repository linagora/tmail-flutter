import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_button_arrow_down_field_widget.dart';

class DefaultButtonArrowDownFieldWithTabKeyWidget extends StatelessWidget {
  final String text;
  final String iconArrowDown;
  final VoidCallback onTap;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;

  const DefaultButtonArrowDownFieldWithTabKeyWidget({
    super.key,
    required this.text,
    required this.iconArrowDown,
    required this.onTap,
    required this.currentFocusNode,
    required this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: currentFocusNode,
      onKeyEvent: _onKeyEvent,
      child: DefaultButtonArrowDownFieldWidget(
        text: text,
        iconArrowDown: iconArrowDown,
        onTap: onTap,
      ),
    );
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.tab) {
      nextFocusNode.requestFocus();
    }
  }
}
