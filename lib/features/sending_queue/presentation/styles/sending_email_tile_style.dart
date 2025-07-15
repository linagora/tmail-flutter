
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';

class SendingEmailTileStyle {
  static const double avatarIconSize = 60;
  static const double avatarIconRadius = 30;
  static const double selectIconSize = 24;
  static const double attachmentIconSize = 20;
  static const double space = 8;
  static const double stateRowWidth = 120;
  static const double stateLabelWidth = 80;

  static const EdgeInsetsGeometry attachmentPadding = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry timeCreatedPadding = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry statePadding = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry statePaddingMobile = EdgeInsetsDirectional.only(top: 8);
  static EdgeInsets getPaddingItemListViewByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    }
  }
  static EdgeInsets getPaddingDividerListViewByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.only(left: 84, right: 8, top: 8);
    } else {
      return const EdgeInsets.only(left: 100, right: 24, top: 8);
    }
  }

  static TextStyle getTitleTextStyle(SendingState state) => ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 15,
    color: state.getTitleSendingEmailItemColor(),
    fontWeight: FontWeight.w600
  );
  static TextStyle getSubTitleTextStyle(SendingState state) => ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 13,
    color: state.getSubTitleSendingEmailItemColor(),
    fontWeight: FontWeight.normal
  );
  static TextStyle getTimeCreatedTextStyle(SendingState state) => ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 13,
    color: state.getTitleSendingEmailItemColor(),
    fontWeight: FontWeight.normal
  );
}