import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/bottom_bar_composer_widget_style.dart';

class DropZoneWidgetStyle {
  static const double space = 20;
  static const double borderWidth = 2;
  static const double radius = 16;

  static const List<double> dashSize = [6, 3];

  static Color backgroundColor = AppColor.colorDropZoneBackground.withValues(alpha: 0.7);
  static const Color borderColor = AppColor.colorDropZoneBorder;

  static const EdgeInsetsGeometry padding = EdgeInsets.all(20);
  static const EdgeInsetsGeometry margin = EdgeInsetsDirectional.only(
    bottom: BottomBarComposerWidgetStyle.height,
    start: 8,
    end: 8,
    top: 8
  );

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 22,
    fontWeight: FontWeight.w600
  );
}