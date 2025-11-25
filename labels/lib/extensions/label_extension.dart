import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/hex_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';

extension LabelExtension on Label {
  static const String moreLabelId = 'more-btn';

  String get safeDisplayName => displayName ?? '';

  Color? get backgroundColor {
    if (id?.value == moreLabelId) {
      return AppColor.grayBackgroundColor;
    } else {
      return color?.value.toColor();
    }
  }

  Color get textColor {
    if (id?.value == moreLabelId) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}
