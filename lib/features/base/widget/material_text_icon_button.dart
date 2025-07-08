
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnTapMaterialTextIconButton = Function();

class MaterialTextIconButton extends StatelessWidget {

  final String label;
  final String icon;
  final OnTapMaterialTextIconButton onTap;
  final double borderRadius;
  final double elevation;
  final double iconSize;
  final Size? minimumSize;
  final Color? labelColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final TextStyle? labelStyle;

  const MaterialTextIconButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.borderRadius = 12,
    this.elevation = 0,
    this.iconSize = 24,
    this.labelColor,
    this.iconColor,
    this.backgroundColor,
    this.labelStyle,
    this.minimumSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: SvgPicture.asset(
        icon,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.fill,
        colorFilter: (iconColor ?? AppColor.colorTextButton).asFilter(),
      ),
      label: Text(
        label,
        style: labelStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 16,
          color: labelColor ?? AppColor.colorTextButton,
          fontWeight: FontWeight.w500
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: labelColor ?? AppColor.colorTextButton,
        backgroundColor: backgroundColor ?? AppColor.colorCreateNewIdentityButton,
        elevation: 0,
        minimumSize: minimumSize,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      )
    );
  }
}