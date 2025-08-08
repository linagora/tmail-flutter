import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArrowDownIconBorderButtonWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final String? icon;
  final IconData? iconData;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? tooltipMessage;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ArrowDownIconBorderButtonWidget({
    super.key,
    required this.imagePaths,
    this.icon,
    this.iconData,
    this.iconColor,
    this.backgroundColor,
    this.tooltipMessage,
    this.height,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null && iconData == null) return const SizedBox.shrink();

    Widget buttonIcon = Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: AppColor.m3Neutral90,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null)
            Icon(iconData, color: iconColor)
          else if (icon != null)
            SvgPicture.asset(
              icon!,
              colorFilter: iconColor.asFilter(),
            ),
          SvgPicture.asset(imagePaths.icStyleArrowDown),
        ],
      ),
    );

    if (onTap != null) {
      buttonIcon = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: buttonIcon,
        ),
      );
    }

    if (tooltipMessage != null) {
      buttonIcon = Tooltip(
        message: tooltipMessage,
        child: buttonIcon,
      );
    }

    if (padding != null) {
      buttonIcon = Padding(padding: padding!, child: buttonIcon);
    }

    return buttonIcon;
  }
}
