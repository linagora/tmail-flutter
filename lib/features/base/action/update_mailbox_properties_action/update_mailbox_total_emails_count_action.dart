import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_properties_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class UpdateMailboxTotalEmailsCountAction extends UpdateMailboxPropertiesAction {
  const UpdateMailboxTotalEmailsCountAction({
    required super.mailboxTrees,
    required super.mailboxId,
    required this.totalEmailsCountChanged,
  });

  final int totalEmailsCountChanged;

  @override
  bool updateProperty(MailboxTree mailboxTree) {
    return mailboxTree.updateMailboxTotalEmailsCountById(
      mailboxId,
      totalEmailsCountChanged,
    );
  }
}