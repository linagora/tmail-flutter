
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class SubjectComposerWidgetStyle {
  static const double space = 12;

  static const Color cursorColor = AppColor.primaryColor;
  static const Color borderColor = AppColor.colorLineComposer;

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.colorLabelComposer
  );
  static const TextStyle inputTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500
  );
}