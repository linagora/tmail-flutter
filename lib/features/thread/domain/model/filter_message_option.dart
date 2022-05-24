
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum FilterMessageOption {
  all,
  unread,
  attachments,
  starred,
}

extension FilterMessageOptionExtension on FilterMessageOption {

  String getIconToast(ImagePaths imagePaths) {
    switch(this) {
      case FilterMessageOption.all:
        return imagePaths.icFilterMessageAll;
      case FilterMessageOption.unread:
        return imagePaths.icUnreadToast;
      case FilterMessageOption.attachments:
        return imagePaths.icFilterMessageAttachments;
      case FilterMessageOption.starred:
        return imagePaths.icStar;
    }
  }

  String getMessageToast(BuildContext context) {
    switch(this) {
      case FilterMessageOption.all:
        return AppLocalizations.of(context).disable_filter_message_toast;
      case FilterMessageOption.unread:
        return AppLocalizations.of(context).filter_message_toast(AppLocalizations.of(context).unread);
      case FilterMessageOption.attachments:
        return AppLocalizations.of(context).filter_message_toast(AppLocalizations.of(context).with_attachments);
      case FilterMessageOption.starred:
        return AppLocalizations.of(context).filter_message_toast(AppLocalizations.of(context).starred);
    }
  }

  String getTitle(BuildContext context) {
    switch(this) {
      case FilterMessageOption.all:
        return '';
      case FilterMessageOption.unread:
        return AppLocalizations.of(context).with_unread;
      case FilterMessageOption.attachments:
        return AppLocalizations.of(context).with_attachments.capitalizeFirstEach;
      case FilterMessageOption.starred:
        return AppLocalizations.of(context).with_starred;
    }
  }

  bool filterPresentationEmail(PresentationEmail email) {
    switch(this) {
      case FilterMessageOption.all:
        return true;
      case FilterMessageOption.unread:
        return !email.hasRead;
      case FilterMessageOption.attachments:
        return email.withAttachments;
      case FilterMessageOption.starred:
        return email.hasStarred;
    }
  }

  bool filterEmail(Email email) {
    switch(this) {
      case FilterMessageOption.all:
        return true;
      case FilterMessageOption.unread:
        return !email.hasRead;
      case FilterMessageOption.attachments:
        return email.withAttachments;
      case FilterMessageOption.starred:
        return email.hasStarred;
    }
  }

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