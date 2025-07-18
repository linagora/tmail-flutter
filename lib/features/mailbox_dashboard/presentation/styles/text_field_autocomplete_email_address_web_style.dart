import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';

class TextFieldAutoCompleteEmailAddressWebStyles {
  static const EdgeInsetsGeometry textInputContentPadding =
      EdgeInsetsDirectional.only(
    top: 14,
    bottom: 14,
    start: 12,
    end: 8,
  );
  static const EdgeInsetsGeometry textInputContentPaddingWithSomeTag =
    EdgeInsetsDirectional.symmetric(vertical: 14);
  static const EdgeInsets tagEditorPadding = EdgeInsets.symmetric(horizontal: 12);

  static const double suggestionBoxRadius = 20.0;

  static const double minTextFieldWidth = 40.0;

  static const double suggestionBoxElevation = 20.0;
  static const double suggestionBoxMaxHeight = 350.0;
  static const double suggestionBoxItemHeight = ComposerStyle.suggestionItemHeight;

  static const double fieldTitleWidth = 112.0;
  static const double space = 12.0;

  static const InputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius)),
    borderSide: BorderSide.none,
  );

  static const Color textInputFillColor = Colors.white;
  static const Color focusedBorderColor = AppColor.primaryColor;
  static const Color suggestionBoxBackgroundColor = Colors.white;
  static const Color cursorColor = AppColor.primaryColor;

  static TextStyle textInputHintStyle = ThemeUtils.textStyleBodyBody3(
    color: AppColor.m3Tertiary,
  );

  static const Duration debounceDuration = Duration(milliseconds: 150);
}