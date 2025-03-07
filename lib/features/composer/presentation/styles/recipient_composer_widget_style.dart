
import 'package:core/presentation/extensions/color_extension.dart';
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

  static const TextStyle prefixButtonTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.underline,
    decorationColor: AppColor.m3Neutral70,
    color: AppColor.m3Neutral70,
  );
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black
  );
}