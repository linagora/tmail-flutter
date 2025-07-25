
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

class RecipientComposerWidgetStyle {
  static const double deleteRecipientFieldIconSize = 20;
  static const double space = 8;
  static const double enableBorderRadius = 10;
  static const double suggestionsBoxElevation = 20.0;
  static const double suggestionsBoxRadius = 20;
  static const double suggestionsBoxMaxHeight = 300;
  static const double suggestionBoxWidth = 300;
  static const double suggestionBoxItemHeight = ComposerStyle.suggestionItemHeight;
  static const double minTextFieldWidth = 20;
  static const double tagSpacing = 8;

  static const Duration suggestionDebounceDuration = Duration(milliseconds: 150);

  static const Color borderColor = AppColor.colorLineComposer;
  static const Color deleteRecipientFieldIconColor = AppColor.colorCollapseMailbox;
  static const Color enableBorderColor = AppColor.primaryColor;
  static const Color suggestionsBoxBackgroundColor = Colors.white;
  static const Color cursorColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry deleteRecipientFieldIconPadding = EdgeInsetsDirectional.all(3);
  static const EdgeInsetsGeometry prefixButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 3, horizontal: 5);
  static const EdgeInsetsGeometry labelMargin = EdgeInsetsDirectional.only(top: 16);
  static const EdgeInsetsGeometry recipientMargin = EdgeInsetsDirectional.only(top: 12);
  static const EdgeInsetsGeometry enableRecipientButtonMargin = EdgeInsetsDirectional.only(top: 10);

  static TextStyle prefixButtonTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontFamily: ConstantsUI.fontApp,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    letterSpacing: -0.01,
    decoration: TextDecoration.underline,
    decorationColor: AppColor.m3Neutral70,
    color: AppColor.m3Neutral70,
  );
  static final TextStyle inputTextStyle = ThemeUtils.textStyleBodyBody1(
    color: AppColor.m3SurfaceBackground,
  );
  static final TextStyle prefixLabelTextStyle = ThemeUtils.textStyleBodyBody1(
    color: AppColor.m3Tertiary,
  );
}