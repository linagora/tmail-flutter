import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/reference_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';

extension MailboxIdExtension on MailboxId {
  String generatePath() {
    if (id is ReferenceId) {
      return '${PatchObject.mailboxIdsProperty}/${id.toString()}';
    } else {
      return '${PatchObject.mailboxIdsProperty}/${id.value}';
    }
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

  PatchObject generateMoveToSpamActionPath(MailboxId currentMailboxId, MailboxId spamMailboxId) {
    return PatchObject({
      currentMailboxId.generatePath():  null,
      spamMailboxId.generatePath(): true,
      KeyWordIdentifier.emailSeen.generatePath(): true
    });
  }

  String get asString => id.value;
}