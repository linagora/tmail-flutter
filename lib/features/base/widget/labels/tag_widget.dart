import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final double horizontalPadding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? maxWidth;
  final bool isTruncateText;
  final bool showTooltip;
  final EdgeInsetsGeometry? margin;

  const TagWidget({
    super.key,
    required this.text,
    this.horizontalPadding = 4,
    this.isTruncateText = false,
    this.showTooltip = false,
    this.backgroundColor,
    this.textColor,
    this.maxWidth,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget labelText = Text(
      isTruncateText ? _truncateName(text) : text,
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
      margin: margin,
      child: labelText,
    );
  }

  String _truncateName(String name, {int maxLength = 16}) {
    try {
      if (name.length <= maxLength) return name;
      return '${name.substring(0, maxLength - 1)}...';
    } catch (_) {
      return name;
    }
  }
}
