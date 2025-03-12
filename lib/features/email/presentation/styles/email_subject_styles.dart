
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class EmailSubjectStyles {
  static int? maxLines = PlatformInfo.isWeb ? 2 : null;

  static const Color cursorColor = AppColor.colorTextButton;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
}