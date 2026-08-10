import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension MapMailboxByIdExtension on Map<MailboxId, PresentationMailbox> {
  /// The child mailbox ids of [parent].
  ///
  /// This runs against `mapMailboxById`, which `_setMapMailbox()` keeps scoped
  /// to the primary account plus the account-less virtual folders, so the
  /// cascade is a primary-account operation and a bare `parentId` match is
  /// sufficient here.
  List<MailboxId> childMailboxIds(PresentationMailbox parent) =>
      values.where((m) => m.parentId == parent.id).map((m) => m.id).toList();
}
