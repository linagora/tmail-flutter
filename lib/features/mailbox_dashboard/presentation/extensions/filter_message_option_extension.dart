
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension FilterMessageOptionExtension on FilterMessageOption {

  String getName(BuildContext context) {
    switch(this) {
      case FilterMessageOption.all:
        return '';
      case FilterMessageOption.unread:
        return AppLocalizations.of(context).unread;
      case FilterMessageOption.attachments:
        return AppLocalizations.of(context).with_attachments;
      case FilterMessageOption.starred:
        return AppLocalizations.of(context).starred;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case FilterMessageOption.all:
        return '';
      case FilterMessageOption.unread:
        return imagePaths.icUnread;
      case FilterMessageOption.attachments:
        return imagePaths.icAttachment;
      case FilterMessageOption.starred:
        return imagePaths.icStar;
    }
  }
}