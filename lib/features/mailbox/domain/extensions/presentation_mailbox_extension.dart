import 'package:core/core.dart';
import 'package:model/model.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  String getMailboxIcon(ImagePaths imagePaths) {
     if (hasRole()) {
        switch(role!.value) {
          case 'inbox':
            return imagePaths.icMailboxInboxV2;
          case 'drafts':
            return imagePaths.icMailboxDraftsV2;
          case 'outbox':
            return imagePaths.icMailboxArchivedV2;
          case 'sent':
            return imagePaths.icMailboxSentV2;
          case 'trash':
            return imagePaths.icMailboxTrashV2;
          case 'spam':
            return imagePaths.icMailboxSpamV2;
          case 'templates':
            return imagePaths.icMailboxTemplate;
          case 'all_mail':
            return imagePaths.icMailboxAllMail;
          default:
            return imagePaths.icFolderMailbox;
        }
     } else {
       return imagePaths.icFolderMailbox;
     }
  }
}