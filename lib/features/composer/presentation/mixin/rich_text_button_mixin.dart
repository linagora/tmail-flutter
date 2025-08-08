import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
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
    late Widget buttonIcon;
    if (tooltip.isNotEmpty) {
      buttonIcon = Tooltip(
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
    } else {
      buttonIcon = Container(
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
      );
    }

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
          colorFilter: isSelected == true
            ? Colors.black.withValues(alpha: opacity).asFilter()
            : AppColor.colorDefaultRichTextButton.withValues(alpha: opacity).asFilter(),
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

    return tooltip?.isNotEmpty == true
      ? Tooltip(
          message: tooltip,
          child: SvgPicture.asset(
            path,
            colorFilter: newColor?.withValues(alpha: opacity).asFilter(),
            fit: BoxFit.fill))
      : SvgPicture.asset(
          path,
          colorFilter: newColor?.withValues(alpha: opacity).asFilter(),
          fit: BoxFit.fill);
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
      message: tooltip,
      child: Icon(iconData,
          color: (newColor ?? AppColor.colorDefaultRichTextButton).withValues(alpha: opacity),
          size: 20),
    );
  }
}