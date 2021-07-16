import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/constants/mailbox_constants.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/list_mailbox_extension.dart';

extension MailboxExtension on Mailbox {

  Mailbox toMailboxSelected(SelectMode selectMode) {
    return Mailbox(
      id,
      name,
      parentId,
      role,
      sortOrder,
      totalEmails,
      unreadEmails,
      totalThreads,
      unreadThreads,
      myRights,
      isSubscribed,
      selectMode: selectMode
    );
  }

  Mailbox qualifyNameMailbox(List<Mailbox> mailboxes) {
    var qualifiedName = name != null ? name!.name : '';

    var parent = mailboxes.findMailboxInList(parentId);

    while (parent != null) {
      qualifiedName = '${parent.name?.name} ${MailboxConstants.MAILBOX_LEVEL_SEPARATOR} $qualifiedName';
      parent = mailboxes.findMailboxInList(parent.parentId);
    }

    return Mailbox(
      id,
      name,
      parentId,
      role,
      sortOrder,
      totalEmails,
      unreadEmails,
      totalThreads,
      unreadThreads,
      myRights,
      isSubscribed,
      qualifiedName: MailboxName(qualifiedName)
    );
  }
}