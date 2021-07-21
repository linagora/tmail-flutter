import 'package:core/presentation/resources/image_paths.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension RoleExtensions on Role {
  String getIconMailbox(ImagePaths imagePaths) {
    switch (this.value) {
      case 'drafts':
        return imagePaths.icMailboxDraft;
      case 'trash':
        return imagePaths.icMailboxTrash;
      case 'spam':
        return imagePaths.icMailboxSpam;
      case 'templates':
        return imagePaths.icMailboxTemplate;
      case 'created_folder':
        return imagePaths.icMailboxNewFolder;
      case 'inbox':
        return imagePaths.icMailboxInbox;
      case 'allMail':
        return imagePaths.icMailboxAllMail;
      case 'outbox':
        return imagePaths.icMailboxFolder;
      case 'sent':
        return imagePaths.icMailboxSent;
      default:
        return imagePaths.icMailboxFolder;
    }
  }
}