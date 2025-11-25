import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final double horizontalPadding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? maxWidth;

  const TagWidget({
    super.key,
    required this.text,
    this.horizontalPadding = 4,
    this.backgroundColor,
    this.textColor,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      constraints:
          maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        text,
        style: ThemeUtils.textStyleContentCaption().copyWith(
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
