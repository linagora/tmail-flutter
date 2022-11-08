
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class GradientColorAvatarIcon extends StatelessWidget {

  final List<Color> colors;
  final double iconSize;
  final double labelFontSize;
  final String label;

  const GradientColorAvatarIcon(this.colors, {
    Key? key,
    this.iconSize = 40,
    this.label = '',
    this.labelFontSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(iconSize * 0.5),
        border: Border.all(color: Colors.transparent),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 1.0],
          colors: colors),
        color: AppColor.avatarColor
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: labelFontSize,
          fontWeight: FontWeight.w600)
      )
    );
  }
}