import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

class TextInputSuggestionFieldWidgetStyles {
  static const double titleWidth = 112.0;
  static const double borderRadius = 10.0;
  static const double borderSize = 1.0;
  static const double minTextFieldWidth = 40.0;
  static const double suggestionsBoxElevation = 20.0;
  static const double suggestionsBoxRadius = 20.0;
  static const double suggestionsBoxMaxHeight = 350.0;
  static const double suggestionBoxItemHeight = ComposerStyle.suggestionItemHeight;
  static const double space = 12.0;
  static const double spaceMobile = 8.0;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
    vertical: 8.0
  );
  static const EdgeInsetsGeometry contentPadding = EdgeInsetsDirectional.symmetric(
    vertical: 16.0
  );
  static const EdgeInsetsGeometry emptyListContentPadding = EdgeInsetsDirectional.only(
    top: 16,
    bottom: 16,
    start: 12
  );

  static const EdgeInsets inputFieldPadding = EdgeInsets.symmetric(
    horizontal: 12.0
  );

  static const InputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  static TextStyle inputFieldTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
}