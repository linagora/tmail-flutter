import 'package:get/get_rx/get_rx.dart';
import 'package:model/mailbox/mailbox_key.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

abstract class UpdateMailboxPropertiesAction {
  const UpdateMailboxPropertiesAction({
    required this.mailboxTrees,
    required this.mailboxKey,
  });

  final List<Rx<MailboxTree>> mailboxTrees;
  final MailboxKey mailboxKey;
  
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