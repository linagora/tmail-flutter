import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class CommonTextStyle {
  static const textStyleNormal = TextStyle(
    color: AppColor.primaryColor,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static const defaultTextOverFlow = TextOverflow.ellipsis;

  static const defaultSoftWrap = true;
}