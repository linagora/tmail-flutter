import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListEmailIdExtension on List<EmailId> {

  List<Id> toIds() => map((emailId) => emailId.id).toList();

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsRead(ReadActions readActions) {
    final Map<Id, PatchObject> maps = {};
    forEach((emailId) {
      maps[emailId.id] = KeyWordIdentifier.emailSeen.generateReadActionPath(readActions);
    });
    return maps;
  }

  Map<Id, PatchObject> generateMapUpdateObjectMoveToMailbox(MailboxId currentMailboxId, MailboxId destinationMailboxId) {
    final Map<Id, PatchObject> maps = {};
    forEach((emailId) {
      maps[emailId.id] = currentMailboxId.generateMoveToMailboxActionPath(destinationMailboxId);
    });
    return maps;
  }

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsStar(MarkStarAction markStarAction) {
    final Map<Id, PatchObject> maps = {};
    forEach((emailId) {
      maps[emailId.id] = KeyWordIdentifier.emailFlagged.generateMarkStarActionPath(markStarAction);
    });
    return maps;
  }

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsSpam(MailboxId spamMailboxId) {
    final Map<Id, PatchObject> maps = {};
    forEach((emailId) {
      maps[emailId.id] = spamMailboxId.generateActionPath();
    });
    return maps;
  }
}