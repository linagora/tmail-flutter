
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension MapMailboxIdExtension on Map<MailboxId, bool> {

  Map<String, bool> toMapString() => Map.fromIterables(keys.map((mailboxId) => mailboxId.id.value), values);
}