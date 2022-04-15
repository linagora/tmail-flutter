import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension MailboxIdExtension on MailboxId {
  String generatePath() {
    return '${PatchObject.mailboxIdsProperty}/${id.value}';
  }

  PatchObject generateMoveToMailboxActionPath(MailboxId destinationMailboxId) {
    return PatchObject({
      generatePath():  null,
      destinationMailboxId.generatePath(): true
    });
  }

  PatchObject generateActionPath() {
    return PatchObject({
      generatePath():  true,
    });
  }
}