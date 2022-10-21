import 'package:core/core.dart';
import 'package:flutter/material.dart';

class CommonTextStyle {
  static const textStyleNormal = TextStyle(
    color: AppColor.primaryColor,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static const defaultTextOverFlow = BuildUtils.isWeb
      ? TextOverflow.fade
      : TextOverflow.ellipsis;

  static const defaultSoftWrap = BuildUtils.isWeb ? false : true;
}