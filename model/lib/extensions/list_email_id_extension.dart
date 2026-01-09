import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListEmailIdExtension on List<EmailId> {

  List<Id> toIds() => map((emailId) => emailId.id).toList();

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsRead(ReadActions readActions) {
    return {
      for (var emailId in this)
        emailId.id: KeyWordIdentifier.emailSeen.generateReadActionPath(readActions)
    };
  }

  Map<Id, PatchObject> generateMapUpdateObjectMoveToMailbox({
    required MailboxId currentMailboxId,
    required MailboxId destinationMailboxId,
    bool markAsRead = false,
  }) {
    return {
      for (var emailId in this)
        emailId.id: currentMailboxId.generateMoveToMailboxActionPath(
          destinationMailboxId: destinationMailboxId,
          markAsRead: markAsRead,
        )
    };
  }

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsStar(MarkStarAction markStarAction) {
    return {
      for (var emailId in this)
        emailId.id: KeyWordIdentifier.emailFlagged.generateMarkStarActionPath(markStarAction)
    };
  }

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsAnswered() {
    return {
      for (var emailId in this)
        emailId.id: KeyWordIdentifier.emailAnswered.generateAnsweredActionPath()
    };
  }

  Map<Id, PatchObject> generateMapUpdateObjectMarkAsForwarded() {
    return {
      for (var emailId in this)
        emailId.id: KeyWordIdentifier.emailForwarded.generateForwardedActionPath()
    };
  }

  Map<Id, PatchObject> generateMapUpdateObjectLabel(
    KeyWordIdentifier labelKeyword,
    {bool remove = false}
  ) {
    return {
      for (var emailId in this)
        emailId.id: labelKeyword.generateLabelActionPath(remove: remove)
    };
  }
}