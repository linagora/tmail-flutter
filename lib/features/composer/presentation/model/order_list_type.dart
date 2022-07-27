
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum OrderListType {
  bulletedList,
  numberedList;

  String get commandAction {
    switch(this) {
      case OrderListType.bulletedList:
        return 'insertUnorderedList';
      case OrderListType.numberedList:
        return 'insertOrderedList';
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case OrderListType.bulletedList:
        return imagePaths.icOrderBullet;
      case OrderListType.numberedList:
        return imagePaths.icOrderNumber;
    }
  }

  String getTooltipButton(BuildContext context) {
    switch (this) {
      case OrderListType.bulletedList:
        return AppLocalizations.of(context).bulletedList;
      case OrderListType.numberedList:
        return AppLocalizations.of(context).numberedList;
    }
  }

  Widget buildButtonWidget(
      BuildContext context,
      ImagePaths imagePaths,
      Function(OrderListType type) onActionCallback
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