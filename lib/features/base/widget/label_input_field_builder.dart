import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';

class LabelInputFieldBuilder extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final String? errorText;
  final String? hintText;
  final TextStyle? labelStyle;
  final FocusNode? focusNode;
  final double? runSpacing;
  final double? inputFieldMaxWidth;
  final bool arrangeHorizontally;
  final bool isLabelHasColon;
  final OnTextChange? onTextChange;

  const LabelInputFieldBuilder({
    super.key,
    required this.label,
    required this.textEditingController,
    this.arrangeHorizontally = true,
    this.isLabelHasColon = true,
    this.hintText,
    this.errorText,
    this.focusNode,
    this.labelStyle,
    this.runSpacing,
    this.inputFieldMaxWidth,
    this.onTextChange,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: inputFieldMaxWidth ?? 565),
      child: DefaultInputFieldWidget(
        textEditingController: textEditingController,
        hintText: hintText,
        errorText: errorText,
        focusNode: focusNode,
        onTextChange: onTextChange,
      ),
    );

    if (arrangeHorizontally) {
      bodyWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 83),
            child: Text(
              isLabelHasColon ? '$label:' : label,
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(child: bodyWidget),
        ],
      );
    } else {
      bodyWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLabelHasColon ? '$label:' : label,
            style: labelStyle ?? ThemeUtils.textStyleBodyBody3(color: Colors.black),
          ),
          SizedBox(height: runSpacing ?? 10),
          bodyWidget,
        ],
      );
    }

    return bodyWidget;
  }
}
