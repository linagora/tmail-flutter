
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class EmailSubjectStyles {
  static const double textSize = 20;
  static int? maxLines = PlatformInfo.isWeb ? 2 : null;
  static int? minLines = PlatformInfo.isWeb ? 1 : null;

  static const Color textColor = AppColor.colorNameEmail;
  static const Color cursorColor = AppColor.colorTextButton;

  static const FontWeight fontWeight = FontWeight.w500;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
}