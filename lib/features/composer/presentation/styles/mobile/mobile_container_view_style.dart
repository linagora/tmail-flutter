import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class MobileContainerViewStyle {
  static const Color outSideBackgroundColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static final Color keyboardToolbarBackgroundColor = PlatformInfo.isIOS
    ? AppColor.colorBackgroundKeyboard
    : AppColor.colorBackgroundKeyboardAndroid;
}