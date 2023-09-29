
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MobileAppBarThreadWidgetStyle {
  static const double buttonMaxWidth = 80;
  static const double titleOffset = 180;
  static const double minHeight = 56;

  static const Color backgroundColor = Colors.white;
  static const Color backButtonColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

  static const TextStyle editButtonStyle = TextStyle(
    fontSize: 17,
    color: AppColor.primaryColor
  );
  static const TextStyle emailCounterTitleStyle = TextStyle(
    fontSize: 17,
    color: AppColor.primaryColor
  );

  static Color getFilterButtonColor(FilterMessageOption option) {
    return option == FilterMessageOption.all
      ? AppColor.colorFilterMessageDisabled
      : AppColor.colorFilterMessageEnabled;
  }
}