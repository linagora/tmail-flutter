import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  String getMailboxIcon(ImagePaths imagePaths) {
     if (hasRole()) {
        switch(role!.value) {
          case 'inbox':
            return imagePaths.icMailboxInbox;
          case 'drafts':
            return imagePaths.icMailboxDrafts;
          case 'outbox':
            return imagePaths.icMailboxOutbox;
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
          default:
            return imagePaths.icFolderMailbox;
        }
     } else {
        return imagePaths.icFolderMailbox;
     }
  }

  Uri get mailboxRouteWeb => RouteUtils.generateRouteBrowser(AppRoutes.dashboard, NavigationRouter(mailboxId: id));
}