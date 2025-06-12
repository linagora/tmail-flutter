import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

class TextFieldAutoCompleteEmailAddressWebStyles {
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsetsGeometry textInputContentPadding = EdgeInsetsDirectional.only(top: 16, bottom: 16, start: 12);
  static const EdgeInsetsGeometry textInputContentPaddingWithSomeTag = EdgeInsetsDirectional.symmetric(vertical: 16);
  static const EdgeInsets tagEditorPadding = EdgeInsets.symmetric(horizontal: 12);

  static const double borderRadius = 10.0;
  static const double suggestionBoxRadius = 20.0;

  static const double borderWidth = 1.0;
  static const double minTextFieldWidth = 40.0;

  static const double suggestionBoxElevation = 20.0;
  static const double suggestionBoxMaxHeight = 350.0;
  static const double suggestionBoxItemHeight = ComposerStyle.suggestionItemHeight;

  static const double fieldTitleWidth = 112.0;
  static const double space = 8.0;

  static const InputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  static const Color textInputFillColor = Colors.white;
  static const Color focusedBorderColor = AppColor.primaryColor;
  static const Color enableBorderColor = AppColor.colorInputBorderCreateMailbox;
  static const Color suggestionBoxBackgroundColor = Colors.white;
  static const Color cursorColor = AppColor.primaryColor;

  static TextStyle textInputHintStyle = ThemeUtils.textStyleBodyBody3(
    color: AppColor.m3Tertiary,
  );
  static const TextStyle textInputTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );

  static const Duration debounceDuration = Duration(milliseconds: 150);
}