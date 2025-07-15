
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';

class SendingStateWidgetStyle {
  static const double space = 4;
  static const double iconSize = 20;
  static const double radius = 16;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 8, vertical: 6);

  static TextStyle getTitleTextStyle(SendingState state) => ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 15,
    color: state.getTitleColor(),
    fontWeight: FontWeight.normal
  );
}