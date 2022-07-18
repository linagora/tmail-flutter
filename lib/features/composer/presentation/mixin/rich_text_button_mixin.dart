
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin RichTextButtonMixin {

  Widget buildIconStyleText({
    required String path,
    required bool? isSelected,
    required VoidCallback onTap,
  }){
    return buildIconWeb(
      icon: SvgPicture.asset(
          path,
          color: isSelected == true
              ? Colors.black
              : AppColor.colorDividerMailbox,
          fit: BoxFit.fill),
      iconPadding: const EdgeInsets.all(4),
      colorFocus: Colors.white,
      minSize: 26,
      onTap: onTap,
    );
  }
}