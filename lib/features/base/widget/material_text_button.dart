
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

typedef OnTapMaterialTextButton = Function();
typedef OnLongPressMaterialTextButton = Function();

class MaterialTextButton extends StatelessWidget {

  final String label;
  final OnTapMaterialTextButton? onTap;
  final OnLongPressMaterialTextButton? onLongPress;
  final double borderRadius;
  final Color? labelColor;
  final double labelSize;
  final FontWeight? labelWeight;
  final TextStyle? customStyle;
  final EdgeInsetsGeometry? padding;
  final TextOverflow? overflow;
  final bool? softWrap;

  const MaterialTextButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = 12,
    this.labelColor,
    this.labelSize = 15,
    this.labelWeight,
    this.customStyle,
    this.padding,
    this.overflow,
    this.softWrap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label,
            overflow: overflow,
            softWrap: softWrap,
            style: customStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: labelSize,
              color: labelColor ?? AppColor.colorTextButton,
              fontWeight: labelWeight ?? FontWeight.normal
            )
          )
        )
      )
    );
  }
}