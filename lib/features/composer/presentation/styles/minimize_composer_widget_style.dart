import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

class MinimizeComposerWidgetStyle {
  static const double radius = 24;
  static const double elevation = 16;
  static const double width = ComposerStyle.minimizeWidth;
  static const double height = ComposerStyle.minimizeHeight;
  static const double space = 8;
  static const double iconSize = 20;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = Colors.black;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 24);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(3);
}