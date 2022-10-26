
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

extension ListMailboxNodeExtension on List<MailboxNode> {
  List<MailboxId> get mailboxIds => map((node) => node.item.id).toList();
}