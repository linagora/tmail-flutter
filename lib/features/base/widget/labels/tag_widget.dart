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

  const TagWidget({
    super.key,
    required this.text,
    this.horizontalPadding = 4,
    this.backgroundColor,
    this.textColor,
    this.maxWidth,
    this.isTruncateText = false,
    this.showTooltip = false,
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

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      constraints:
          maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: labelText,
    );
  }
}
