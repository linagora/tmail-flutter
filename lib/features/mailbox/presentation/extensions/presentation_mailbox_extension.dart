
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  String getDisplayName(BuildContext context) {
    return getDisplayNameByAppLocalizations(AppLocalizations.of(context));
  }

  String getDisplayNameByAppLocalizations(AppLocalizations appLocalizations) {
    if (isDefault) {
      switch(role!.value.toLowerCase()) {
        case PresentationMailbox.inboxRole:
          return appLocalizations.inboxMailboxDisplayName;
        case PresentationMailbox.archiveRole:
          return appLocalizations.archiveMailboxDisplayName;
        case PresentationMailbox.draftsRole:
          return appLocalizations.draftsMailboxDisplayName;
        case PresentationMailbox.sentRole:
          return appLocalizations.sentMailboxDisplayName;
        case PresentationMailbox.outboxRole:
          return appLocalizations.outboxMailboxDisplayName;
        case PresentationMailbox.trashRole:
          return appLocalizations.trashMailboxDisplayName;
        case PresentationMailbox.spamRole:
        case PresentationMailbox.junkRole:
          return appLocalizations.spamMailboxDisplayName;
        case PresentationMailbox.templatesRole:
          return appLocalizations.templatesMailboxDisplayName;
        case PresentationMailbox.recoveredRole:
          return appLocalizations.recoveredMailboxDisplayName;
      }
    }
    return name?.name ?? '';
  }

  String getMailboxIcon(ImagePaths imagePaths) {
    if (hasRole()) {
      switch(role!.value) {
        case PresentationMailbox.inboxRole:
          return imagePaths.icMailboxInbox;
        case PresentationMailbox.draftsRole:
          return imagePaths.icMailboxDrafts;
        case PresentationMailbox.outboxRole:
          return imagePaths.icMailboxOutbox;
        case PresentationMailbox.archiveRole:
          return imagePaths.icMailboxArchived;
        case PresentationMailbox.sentRole:
          return imagePaths.icMailboxSent;
        case PresentationMailbox.trashRole:
          return imagePaths.icMailboxTrash;
        case PresentationMailbox.spamRole:
        case PresentationMailbox.junkRole:
          return imagePaths.icMailboxSpam;
        case PresentationMailbox.templatesRole:
          return imagePaths.icMailboxTemplate;
        case PresentationMailbox.recoveredRole:
          return imagePaths.icRecoverDeletedMessages;
        case 'all_mail':
          return imagePaths.icMailboxAllMail;
        default:
          return imagePaths.icFolderMailbox;
      }
    } else if (isChildOfTeamMailboxes) {
      switch(name!.name.toLowerCase()) {
        case 'inbox':
          return imagePaths.icMailboxInbox;
        case 'outbox':
          return imagePaths.icMailboxOutbox;
        case 'drafts':
          return imagePaths.icMailboxDrafts;
        case 'archive':
          return imagePaths.icMailboxArchived;
        case 'sent':
          return imagePaths.icMailboxSent;
        case 'trash':
          return imagePaths.icMailboxTrash;
        case 'spam':
          return imagePaths.icMailboxSpam;
        case 'templates':
          return imagePaths.icMailboxTemplate;
        case 'restored messages':
          return imagePaths.icRecoverDeletedMessages;
        default:
          return imagePaths.icFolderMailbox;
      }
    } else {
      return imagePaths.icFolderMailbox;
    }
  }

  Uri get mailboxRouteWeb => RouteUtils.createUrlWebLocationBar(
    AppRoutes.dashboard,
    router: NavigationRouter(mailboxId: id)
  );
}