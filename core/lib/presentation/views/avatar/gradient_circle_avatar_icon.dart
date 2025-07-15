
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class GradientCircleAvatarIcon extends StatelessWidget {

  final List<Color> colors;
  final double iconSize;
  final double labelFontSize;
  final String label;
  final TextStyle? textStyle;

  const GradientCircleAvatarIcon({
    Key? key,
    required this.colors,
    this.iconSize = 40,
    this.label = '',
    this.labelFontSize = 24.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 1.0],
          colors: colors
        ),
        color: AppColor.avatarColor
      ),
      child: DefaultTextStyle(
        style: textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
          color: Colors.white,
          fontSize: labelFontSize,
          fontWeight: FontWeight.w600
        ),
        child: Text(label),
      )
    );
  }
}