import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/widget/labels/tag_widget.dart';

class LabelWidget extends StatelessWidget {
  final Label label;
  final double horizontalPadding;
  final double? maxWidth;

  const LabelWidget({
    super.key,
    required this.label,
    this.horizontalPadding = 4,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return TagWidget(
      text: label.safeDisplayName,
      backgroundColor: label.backgroundColor,
      textColor: label.textColor,
      horizontalPadding: horizontalPadding,
      maxWidth: maxWidth,
    );
  }
}
