import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';

typedef OnTextSubmitted = void Function(String text);
typedef OnTextChange = void Function(String text);

class DefaultInputFieldWithTabKeyWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;
  final String? hintText;
  final OnTextChange? onTextChange;
  final OnTextSubmitted? onTextSubmitted;
  final EdgeInsetsGeometry? padding;

  const DefaultInputFieldWithTabKeyWidget({
    super.key,
    required this.textEditingController,
    required this.currentFocusNode,
    required this.nextFocusNode,
    this.hintText,
    this.onTextChange,
    this.onTextSubmitted,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = KeyboardListener(
      focusNode: currentFocusNode,
      onKeyEvent: _onKeyEvent,
      child: DefaultInputFieldWidget(
        textEditingController: textEditingController,
        hintText: hintText,
        onTextChange: onTextChange,
        onTextSubmitted: onTextSubmitted,
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.tab) {
      nextFocusNode.requestFocus();
    }
  }
}
