import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JmapMailbox;

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

  Mailbox toMailboxParent(String nameMailbox) {
    return Mailbox(
        id,
        MailboxName(nameMailbox),
        parentId,
        role,
        sortOrder,
        totalEmails,
        unreadEmails,
        totalThreads,
        unreadThreads,
        myRights,
        isSubscribed
    );
  }

  String getNameMailboxFolderHasParentId(List<Mailbox> mailboxList) {
    final listMailboxParent = <Mailbox>[];
    listMailboxParent.addAll(getRootFolder(mailboxList, this));
    if (listMailboxParent.length > 0) {
      var nameMailbox = '';
      listMailboxParent.forEach((mailbox) {
        nameMailbox += '${mailbox.getNameMailbox()} / ';
      });
      nameMailbox += '${getNameMailbox()}';
      return nameMailbox;
    }
    return getNameMailbox();
  }

  List<Mailbox> getRootFolder(List<Mailbox> mailboxList, Mailbox currentMailbox) {
    final listMailbox = <Mailbox>[];
    final listMailboxParent = mailboxList.where((mailbox) => (mailbox.id == currentMailbox.parentId)).toList();
    if (listMailboxParent.isNotEmpty) {
      if (listMailboxParent.first.hasParentId()) {
        listMailbox.addAll(getRootFolder(mailboxList, listMailboxParent.first));
      } else {
        listMailbox.add(listMailboxParent.first);
      }
    }
    return listMailbox;
  }
}