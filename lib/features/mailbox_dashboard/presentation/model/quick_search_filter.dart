
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum QuickSearchFilter {
  hasAttachment,
  last7Days,
  fromMe
}

extension QuickSearchFilterExtension on QuickSearchFilter {

  String getTitle(BuildContext context, {EmailReceiveTimeType? receiveTimeType}) {
    switch(this) {
      case QuickSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
      case QuickSearchFilter.last7Days:
        if (receiveTimeType != null) {
          return receiveTimeType.getTitle(context);
        }
        return AppLocalizations.of(context).last7Days;
      case QuickSearchFilter.fromMe:
        return AppLocalizations.of(context).fromMe;
    }
  }

  String getIcon(ImagePaths imagePaths, bool isSelected) {

    if (isSelected) {
      return imagePaths.icSelectedSB;
    } else {
      switch(this) {
        case QuickSearchFilter.hasAttachment:
          return imagePaths.icAttachmentSB;
        case QuickSearchFilter.last7Days:
          return imagePaths.icCalendarSB;
        case QuickSearchFilter.fromMe:
          return imagePaths.icUserSB;
      }
    }
  }

  Color getBackgroundColor(bool isSelected) {

    if (isSelected) {
      return AppColor.colorItemEmailSelectedDesktop;
    } else {
      return AppColor.colorButtonHeaderThread;
    }
  }

  TextStyle getTextStyle(bool isSelected) {

    if (isSelected) {
      return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColor.colorTextButton);
    } else {
      return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColor.colorTextButtonHeaderThread);
    }
  }
}