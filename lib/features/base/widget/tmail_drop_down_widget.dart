import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class TMailDropDownWidget extends StatelessWidget {

  final String text;
  final String dropDownIcon;
  final VoidCallback onTap;
  final double? width;
  final Color? backgroundColor;

  const TMailDropDownWidget({
    super.key,
    required this.text,
    required this.dropDownIcon,
    required this.onTap,
    this.width,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget(
      text: text,
      icon: dropDownIcon,
      iconAlignment: TextDirection.rtl,
      width: width,
      height: 40,
      borderRadius: 10,
      backgroundColor: backgroundColor ?? Colors.transparent,
      iconSize: 20,
      iconColor: AppColor.lightIconTertiary,
      padding: const EdgeInsetsDirectional.only(
        start: 12,
        end: 8,
        top: 8,
        bottom: 8,
      ),
      textStyle: ThemeUtils.textStyleBodyBody3(color: Colors.black),
      border: Border.all(width: 1, color: AppColor.m3Neutral90),
      isTextExpanded: true,
      onTapActionCallback: onTap,
    );
  }
}
