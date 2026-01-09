import 'package:core/core.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final double horizontalPadding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? maxWidth;
  final bool isTruncateText;
  final bool showTooltip;
  final Widget? actionWidget;
  final EdgeInsetsGeometry? padding;

  const TagWidget({
    super.key,
    required this.text,
    this.horizontalPadding = 4,
    this.backgroundColor,
    this.textColor,
    this.maxWidth,
    this.isTruncateText = false,
    this.showTooltip = false,
    this.actionWidget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget labelText = Text(
      isTruncateText ? LabelUtils.truncateLabel(text) : text,
      style: ThemeUtils.textStyleContentCaption().copyWith(
        color: textColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (showTooltip) {
      labelText = Tooltip(
        message: text,
        child: labelText,
      );
    }

    if (actionWidget != null) {
      labelText = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: labelText),
          actionWidget!,
        ],
      );
    }

    labelText = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      constraints:
          maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: labelText,
    );

    if (actionWidget != null) {
      labelText = GestureDetector(onTap: () {}, child: labelText);
    }

    return labelText;
  }
}
