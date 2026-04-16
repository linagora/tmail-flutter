import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/labels/tag_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AiActionWidget extends StatelessWidget {
  final double horizontalPadding;
  final double? maxWidth;
  final Widget? actionWidget;
  final EdgeInsetsGeometry? padding;

  const AiActionWidget({
    super.key,
    this.horizontalPadding = 4,
    this.maxWidth,
    this.actionWidget,
    this.padding,
  });

  factory AiActionWidget.create({
    required Widget removeLabelAction,
    EdgeInsetsGeometry? padding,
  }) =>
      AiActionWidget(
        actionWidget: removeLabelAction,
        padding: padding,
      );

  @override
  Widget build(BuildContext context) {
    final showTooltip = PlatformInfo.isWeb;

    return TagWidget(
      text: AppLocalizations.of(context).actionRequired,
      backgroundColor: AppColor.aiActionTag,
      textColor: Colors.white,
      horizontalPadding: horizontalPadding,
      maxWidth: maxWidth,
      showTooltip: showTooltip,
      actionWidget: actionWidget,
      padding: padding,
    );
  }
}
