
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
    double opacity = 1.0,
    EdgeInsets? padding,
  }){
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            color: isSelected == true
                ? AppColor.colorBackgroundWrapIconStyleCode.withOpacity(opacity)
                : Colors.white.withOpacity(opacity),
            border: Border.all(
                color: AppColor.colorBorderWrapIconStyleCode,
                width: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: hasDropdown
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SvgPicture.asset(_imagePaths.icStyleArrowDown)
              ])
          : icon,
      ),
    );
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