import 'package:core/core.dart';
import 'package:flutter/material.dart';

class CommonTextStyle {
  static final textStyleNormal = TextStyle(
    color: AppColor.primaryColor,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static final defaultTextOverFlow = BuildUtils.isWeb ? null : TextOverflow.ellipsis;
}