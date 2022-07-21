
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum RichTextStyleType {
  fontName,
  bold,
  italic,
  underline,
  strikeThrough,
  textColor,
  textBackgroundColor;

  String get commandAction {
    switch (this) {
      case fontName:
        return 'fontName';
      case bold:
        return 'bold';
      case italic:
        return 'italic';
      case underline:
        return 'underline';
      case strikeThrough:
        return 'strikeThrough';
      case textColor:
        return 'foreColor';
      case textBackgroundColor:
        return 'hiliteColor';
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
      default:
        return '';
    }
  }
}