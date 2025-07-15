import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class FromComposerMobileWidgetStyle {
  static const double space = 8.0;
  static const double identityButtonHeight = 32.0;

  static const EdgeInsetsGeometry identityButtonInkWellPadding = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsetsGeometry identityButtonPadding = EdgeInsets.only(
    top: 4,
    bottom: 4,
    left: 8,
  );

  static const BorderRadius identityButtonInkWellBorderRadius = BorderRadius.all(Radius.circular(10));
  static const BoxDecoration identityButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    color: AppColor.colorComposerAppBar,
  );
  static const Border border = Border(
    bottom: BorderSide(
      color: AppColor.colorLineComposer,
      width: 1,
    )
  );

  static TextStyle prefixTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.colorLabelComposer
  );
  static TextStyle buttonTitleTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorCalendarEventUnread,
    overflow: TextOverflow.ellipsis,
  );
  static TextStyle buttonSubTitleTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorLabelComposer,
    overflow: TextOverflow.ellipsis,
  );
}