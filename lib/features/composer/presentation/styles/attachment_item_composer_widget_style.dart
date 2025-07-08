import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AttachmentItemComposerWidgetStyle {
  static const double radius = 8;
  static const double iconSize = 20;
  static const double space = 8;
  static const double deleteIconSize = 18;
  static const double deleteIconRadius = 10;
  static const double width = 260;

  static const Color borderColor = AppColor.colorAttachmentBorder;
  static const Color backgroundColor = Colors.white;
  static const Color deleteIconColor = AppColor.colorRichButtonComposer;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.all(8);
  static const EdgeInsetsGeometry deleteIconPadding = EdgeInsetsDirectional.all(3);
  static const EdgeInsetsGeometry progressLoadingPadding = EdgeInsetsDirectional.only(top: 8);

  static TextStyle labelTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
  static TextStyle dotsLabelTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 12,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
  static TextStyle sizeLabelTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 11,
    color: AppColor.colorLabelComposer,
    fontWeight: FontWeight.w500,
  );
}