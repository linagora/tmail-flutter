
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

mixin RichTextButtonMixin {

  final _imagePaths = Get.find<ImagePaths>();

  Widget buildWrapIconStyleText({
    required Widget icon,
    VoidCallback? onTap,
    bool isSelected = false,
    bool hasDropdown = true,
    EdgeInsets? padding,
    double? spacing,
    String tooltip = '',
  }){
    final buttonIcon = Tooltip(
      message: tooltip,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            color: isSelected == true
                ? AppColor.colorBackgroundWrapIconStyleCode
                : Colors.white,
            border: Border.all(
                color: AppColor.colorBorderWrapIconStyleCode,
                width: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: hasDropdown
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  if (spacing != null) SizedBox(width: spacing),
                  SvgPicture.asset(_imagePaths.icStyleArrowDown)
                ])
            : icon,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: buttonIcon,
      );
    } else {
      return buttonIcon;
    }
  }

  Widget buildIconStyleText({
    required String path,
    required bool? isSelected,
    required VoidCallback onTap,
    String? tooltip,
    double opacity = 1.0,
  }){
    return buildIconWeb(
      icon: SvgPicture.asset(
          path,
          color: isSelected == true
              ? Colors.black.withOpacity(opacity)
              : AppColor.colorDefaultRichTextButton.withOpacity(opacity),
          fit: BoxFit.fill),
      iconPadding: const EdgeInsets.all(4),
      colorFocus: Colors.white,
      minSize: 26,
      tooltip: tooltip,
      onTap: onTap,
    );
  }

  Widget buildIconWithTooltip({
    required String path,
    Color? color,
    String? tooltip,
    double opacity = 1.0,
  }){
    final newColor = color == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : color;

    return Tooltip(
      child: SvgPicture.asset(path,
        color: newColor?.withOpacity(opacity),
        fit: BoxFit.fill),
      message: tooltip,
    );
  }

  Widget buildIcon({
    required String path,
    Color? color,
    double opacity = 1.0,
  }){
    final newColor = color == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : color;

    return SvgPicture.asset(path,
        color: newColor?.withOpacity(opacity),
        fit: BoxFit.fill);
  }

  Widget buildIconColorBackgroundTextWithoutTooltip({
    required IconData? iconData,
    required Color? colorSelected,
    double opacity = 1.0,
  }){
    final newColor = colorSelected == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : colorSelected;
    return Icon(iconData,
        color: (newColor ?? AppColor.colorDefaultRichTextButton).withOpacity(opacity),
        size: 20);
  }

  Widget buildIconColorBackgroundText({
    required IconData? iconData,
    required Color? colorSelected,
    String? tooltip,
    double opacity = 1.0,
  }){
    final newColor = colorSelected == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : colorSelected;
    return Tooltip(
      child: Icon(iconData,
          color: (newColor ?? AppColor.colorDefaultRichTextButton).withOpacity(opacity),
          size: 20),
      message: tooltip,
    );
  }
}