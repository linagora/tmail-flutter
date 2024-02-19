
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension ListPresentationMailboxExtension on List<PresentationMailbox> {

  List<PresentationMailbox> get listSubscribedMailboxesAndDefaultMailboxes =>
    where((mailbox) => mailbox.isSubscribedMailbox || mailbox.isDefault).toList();
  
  List<PresentationMailbox> get listUnsubscribedMailboxes =>
    where((mailbox) => !mailbox.isSubscribedMailbox).toList();

  List<PresentationMailbox> get listPersonalMailboxes =>
    where((mailbox) => mailbox.isPersonal).toList();

  bool get isAllPersonalMailboxes => every((mailbox) => mailbox.isPersonal && !mailbox.isDefault);

  bool get isAllDefaultMailboxes => every((mailbox) => mailbox.isDefault);

  bool get isAllUnreadMailboxes => every((mailbox) => mailbox.countUnReadEmailsAsString.isNotEmpty);

  List<MailboxId> get mailboxIds => map((mailbox) => mailbox.id).toList();
}