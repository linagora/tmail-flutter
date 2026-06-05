import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension MapMailboxByIdExtension on Map<MailboxId, PresentationMailbox> {
  List<MailboxId> childMailboxIds(PresentationMailbox parent) =>
      values.where((m) => m.parentId == parent.id).map((m) => m.id).toList();
}
