
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  String getDisplayName(BuildContext context) {
    if (isDefault) {
      log("PresentationMailboxExtension::getDisplayName:Role: $role | MailboxName: $name");
      switch(role!.value.toLowerCase()) {
        case PresentationMailbox.inboxRole:
          return AppLocalizations.of(context).inboxMailboxDisplayName;
        case PresentationMailbox.archiveRole:
          return AppLocalizations.of(context).archiveMailboxDisplayName;
        case PresentationMailbox.draftsRole:
          return AppLocalizations.of(context).draftsMailboxDisplayName;
        case PresentationMailbox.sentRole:
          return AppLocalizations.of(context).sentMailboxDisplayName;
        case PresentationMailbox.outboxRole:
          return AppLocalizations.of(context).outboxMailboxDisplayName;
        case PresentationMailbox.trashRole:
          return AppLocalizations.of(context).trashMailboxDisplayName;
        case PresentationMailbox.spamRole:
          return AppLocalizations.of(context).spamMailboxDisplayName;
        case PresentationMailbox.templatesRole:
          return AppLocalizations.of(context).templatesMailboxDisplayName;
      }
    }
    return name?.name ?? '';
  }
}