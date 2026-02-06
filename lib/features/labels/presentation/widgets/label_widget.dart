import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/widget/labels/tag_widget.dart';

class LabelWidget extends StatelessWidget {
  final Label label;
  final double horizontalPadding;
  final double? maxWidth;
  final bool isTruncateLabel;
  final Widget? actionWidget;
  final EdgeInsetsGeometry? padding;

  const LabelWidget({
    super.key,
    required this.label,
    this.horizontalPadding = 4,
    this.maxWidth,
    this.isTruncateLabel = false,
    this.actionWidget,
    this.padding,
  });

  factory LabelWidget.create({
    required Label label,
    required Widget removeLabelAction,
    EdgeInsetsGeometry? padding,
  }) =>
      LabelWidget(
        label: label,
        actionWidget: removeLabelAction,
        padding: padding,
      );

  @override
  Widget build(BuildContext context) {
    final showTooltip =
        PlatformInfo.isWeb && label.id?.value != LabelExtension.moreLabelId;

    return TagWidget(
      text: label.safeDisplayName,
      backgroundColor: label.backgroundColor,
      textColor: label.textColor,
      horizontalPadding: horizontalPadding,
      maxWidth: maxWidth,
      isTruncateText: isTruncateLabel,
      showTooltip: showTooltip,
      actionWidget: actionWidget,
      padding: padding,
    );
  }
}
