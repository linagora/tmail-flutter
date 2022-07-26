
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ParagraphType {
  alignLeft,
  alignRight,
  alignCenter,
  justify,
  indent,
  outdent;

  String get commandAction {
    switch(this) {
      case ParagraphType.alignLeft:
        return 'justifyLeft';
      case ParagraphType.alignRight:
        return 'justifyRight';
      case ParagraphType.alignCenter:
        return 'justifyCenter';
      case ParagraphType.justify:
        return 'justifyFull';
      case ParagraphType.indent:
        return 'indent';
      case ParagraphType.outdent:
        return 'outdent';
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case ParagraphType.alignLeft:
        return imagePaths.icAlignLeft;
      case ParagraphType.alignRight:
        return imagePaths.icAlignRight;
      case ParagraphType.alignCenter:
        return imagePaths.icAlignCenter;
      case ParagraphType.justify:
        return imagePaths.icAlignJustify;
      case ParagraphType.indent:
        return imagePaths.icAlignIndent;
      case ParagraphType.outdent:
        return imagePaths.icAlignOutdent;
    }
  }

  String getTooltipButton(BuildContext context) {
    switch (this) {
      case ParagraphType.alignLeft:
        return AppLocalizations.of(context).alignLeft;
      case ParagraphType.alignRight:
        return AppLocalizations.of(context).alignRight;
      case ParagraphType.alignCenter:
        return AppLocalizations.of(context).alignCenter;
      case ParagraphType.justify:
        return AppLocalizations.of(context).justifyFull;
      case ParagraphType.indent:
        return AppLocalizations.of(context).indent;
      case ParagraphType.outdent:
        return AppLocalizations.of(context).outdent;
    }
  }

  Widget buildButtonWidget(
      BuildContext context,
      ImagePaths imagePaths,
      Function(ParagraphType paragraph) onActionCallback
  ) {
    return buildIconWeb(
        icon: SvgPicture.asset(getIcon(imagePaths)),
        iconPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        minSize: 30,
        iconSize: 30,
        tooltip: getTooltipButton(context),
        onTap: () => onActionCallback.call(this));
  }
}