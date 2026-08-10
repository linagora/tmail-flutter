import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension MapMailboxByIdExtension on Map<MailboxId, PresentationMailbox> {
  /// The child mailbox ids of [parent], scoped to the parent's own account.
  ///
  /// JMAP ids collide across accounts, so matching on `parentId` alone would let
  /// a delegated parent pick up an identically numbered primary folder's
  /// children (and vice versa) and empty the wrong subfolders. Comparing the
  /// account too keeps the cascade within the account the empty runs against.
  List<MailboxId> childMailboxIds(PresentationMailbox parent) =>
      values
          .where((m) => m.parentId == parent.id && m.accountId == parent.accountId)
          .map((m) => m.id)
          .toList();
}
