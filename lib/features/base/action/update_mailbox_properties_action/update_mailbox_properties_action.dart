import 'package:get/get_rx/get_rx.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

abstract class UpdateMailboxPropertiesAction {
  const UpdateMailboxPropertiesAction({
    required this.mailboxTrees,
    required this.mailboxId,
  });

  final List<Rx<MailboxTree>> mailboxTrees;
  final MailboxId mailboxId;
  
  bool updateProperty(MailboxTree mailboxTree);

  void execute() {
    for (var mailboxTree in mailboxTrees) {
      if (updateProperty(mailboxTree.value)) {
        mailboxTree.refresh();
        break;
      }
    }
  }
}