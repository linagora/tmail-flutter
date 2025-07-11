import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_label_field_widget.dart';

class DefaultHorizontalFieldWidget extends StatelessWidget {

  final String label;
  final Widget child;
  final double labelMaxWidth;
  final bool useHeight;

  const DefaultHorizontalFieldWidget({
    super.key,
    required this.label,
    required this.child,
    this.labelMaxWidth = 112,
    this.useHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelMaxWidth,
          child: DefaultLabelFieldWidget(label: label),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );

    if (useHeight) {
      return SizedBox(height: 40, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
