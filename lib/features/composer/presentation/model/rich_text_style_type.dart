
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum RichTextStyleType {
  headerStyle,
  fontName,
  fontSize,
  bold,
  italic,
  underline,
  strikeThrough,
  textColor,
  textBackgroundColor,
  paragraph,
  orderList;

  String get commandAction {
    switch (this) {
      case headerStyle:
        return 'formatBlock';
      default:
        return '';
    }
  }

  String get summernoteNameAPI {
    switch (this) {
      case textColor:
        return 'foreColor';
      case textBackgroundColor:
        return 'backColor';
      case fontName:
        return 'fontName';
      case bold:
        return 'bold';
      case italic:
        return 'italic';
      case underline:
        return 'underline';
      case strikeThrough:
        return 'strikethrough';
      default:
        return '';
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case bold:
        return imagePaths.icStyleBold;
      case italic:
        return imagePaths.icStyleItalic;
      case underline:
        return imagePaths.icStyleUnderline;
      case strikeThrough:
        return imagePaths.icStyleStrikeThrough;
      case headerStyle:
        return imagePaths.icStyleHeader;
      case textColor:
      case textBackgroundColor:
        return imagePaths.icStyleColor;
      default:
        return '';
    }
  }

  IconData? getIconData() {
    switch (this) {
      case textColor:
        return Icons.format_color_text;
      case textBackgroundColor:
        return Icons.format_color_fill;
      default:
        return null;
    }
  }

  String getTooltipButton(BuildContext context) {
    switch (this) {
      case bold:
        return AppLocalizations.of(context).formatBold;
      case italic:
        return AppLocalizations.of(context).formatItalic;
      case underline:
        return AppLocalizations.of(context).formatUnderline;
      case strikeThrough:
        return AppLocalizations.of(context).formatStrikethrough;
      case textColor:
        return AppLocalizations.of(context).formatTextColor;
      case textBackgroundColor:
        return AppLocalizations.of(context).formatTextBackgroundColor;
      case headerStyle:
        return AppLocalizations.of(context).headerStyle;
      case fontName:
        return AppLocalizations.of(context).fontFamily;
      case fontSize:
        return AppLocalizations.of(context).textSize;
      case paragraph:
        return AppLocalizations.of(context).paragraph;
      case orderList:
        return AppLocalizations.of(context).orderList;
      default:
        return '';
    }
  }
}