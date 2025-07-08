import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

class SuggestionItemWidgetStyles {
  static const double iconSelectedSize = 24.0;
  static const double suggestionItemHeight = ComposerStyle.suggestionItemHeight;

  static const EdgeInsetsGeometry margin = EdgeInsets.all(8.0);
  static const EdgeInsetsGeometry contentPaddingDuplicated = EdgeInsets.symmetric(
    horizontal: 8.0
  );
  static const EdgeInsetsGeometry contentPaddingValid = EdgeInsets.symmetric(
    horizontal: 16.0
  );

  static const BoxDecoration decoration = BoxDecoration(
    color: AppColor.colorBgMenuItemDropDownSelected,
    borderRadius: BorderRadius.all(Radius.circular(20))
  );

  static TextStyle subTitleTextOriginStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: AppColor.colorHintSearchBar,
    fontSize: 13,
    fontWeight: FontWeight.normal
  );
  static TextStyle subTitleWordSearchedStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.bold
  );
}