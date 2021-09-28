
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';

extension MailboxChangeResponseExtension on MailboxChangeResponse {

  MailboxChangeResponse updatedMailboxChangeResponse(List<Mailbox>? updatedMailbox) {
    return MailboxChangeResponse(
      updated: updatedMailbox,
      created: created,
      destroyed: destroyed,
      newStateMailbox: newStateMailbox,
      newStateChanges: newStateChanges,
      hasMoreChanges: hasMoreChanges,
      updatedProperties: updatedProperties
    );
  }
}