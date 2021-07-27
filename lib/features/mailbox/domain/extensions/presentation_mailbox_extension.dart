import 'package:core/core.dart';
import 'package:model/model.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  String getMailboxIcon(ImagePaths imagePaths) {
     if (hasRole()) {
        switch(role!.value) {
          case 'inbox':
            return imagePaths.icMailboxInbox;
          case 'drafts':
            return imagePaths.icMailboxDrafts;
          case 'outbox':
            return imagePaths.icMailboxInbox;
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
            return imagePaths.icMailboxFolder;
        }
     } else {
       return imagePaths.icMailboxFolder;
     }
  }
}