import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_properties_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class UpdateMailboxNameAction extends UpdateMailboxPropertiesAction {
  const UpdateMailboxNameAction({
    required super.mailboxTrees,
    required super.mailboxId,
    required this.mailboxName,
  });

  final MailboxName mailboxName;
  
  @override
  bool updateProperty(MailboxTree mailboxTree) {
    return mailboxTree.updateMailboxNameById(mailboxId, mailboxName);
  }
}