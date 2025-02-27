
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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
        return AppLocalizations.of(context).filter_messages;
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

  String getContextMenuIcon(ImagePaths imagePaths) {
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

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case FilterMessageOption.all:
        return imagePaths.icFilterAdvanced;
      case FilterMessageOption.unread:
      case FilterMessageOption.attachments:
      case FilterMessageOption.starred:
        return imagePaths.icSelectedSB;
    }
  }

  Color getIconColor() {
    switch(this) {
      case FilterMessageOption.all:
        return AppColor.colorFilterMessageIcon;
      case FilterMessageOption.unread:
      case FilterMessageOption.attachments:
      case FilterMessageOption.starred:
        return AppColor.primaryColor;
    }
  }

  Color getBackgroundColor({bool isSelected = false}) {
    if (isSelected) {
      return AppColor.primaryColor.withOpacity(0.06);
    } else {
      return AppColor.colorFilterMessageButton.withOpacity(0.6);
    }
  }

  TextStyle getTextStyle() {
    switch(this) {
      case FilterMessageOption.all:
        return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColor.colorFilterMessageTitle);
      case FilterMessageOption.unread:
      case FilterMessageOption.attachments:
      case FilterMessageOption.starred:
        return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryColor);
    }
  }

  EmailFilterCondition getFilterCondition({
    PresentationEmail? oldestEmail,
    MailboxId? mailboxIdSelected,
  }) {
    switch(this) {
      case FilterMessageOption.all:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          before: oldestEmail?.receivedAt,
        );
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: oldestEmail?.receivedAt,
        );
      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasAttachment: true,
          before: oldestEmail?.receivedAt,
        );
      case FilterMessageOption.starred:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: oldestEmail?.receivedAt,
        );
    }
  }
}