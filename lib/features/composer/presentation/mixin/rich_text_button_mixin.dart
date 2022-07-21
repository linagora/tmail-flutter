
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin RichTextButtonMixin {

  Widget buildIconStyleText({
    required String path,
    required bool? isSelected,
    required VoidCallback onTap,
    String? tooltip
  }){
    return buildIconWeb(
      icon: SvgPicture.asset(
          path,
          color: isSelected == true
              ? Colors.black
              : AppColor.colorDefaultRichTextButton,
          fit: BoxFit.fill),
      iconPadding: const EdgeInsets.all(4),
      colorFocus: Colors.white,
      minSize: 26,
      tooltip: tooltip,
      onTap: onTap,
    );
  }

  Widget buildIconColorText({
    required IconData? iconData,
    required Color? colorSelected,
    required VoidCallback onTap,
    String? tooltip
  }){
    final newColor = colorSelected == Colors.transparent
        ? AppColor.colorDefaultRichTextButton
        : colorSelected;
    return buildIconWeb(
      icon: Icon(iconData, color: newColor ?? Colors.black, size: 20),
      iconPadding: const EdgeInsets.all(4),
      colorSelected: newColor == Colors.white
        ? AppColor.colorFocusRichTextButton
        : Colors.transparent,
      colorFocus: Colors.white,
      minSize: 20,
      tooltip: tooltip,
      onTap: onTap,
    );
  }
}