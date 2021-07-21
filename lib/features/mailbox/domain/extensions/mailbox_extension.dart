import 'package:model/model.dart';

extension MailboxExtension on PresentationMailbox {

  PresentationMailbox toMailboxSelected(SelectMode selectMode) {
    return PresentationMailbox(
      id,
      name: name,
      parentId: parentId,
      role: role,
      sortOrder: sortOrder,
      totalEmails: totalEmails,
      unreadEmails: unreadEmails,
      totalThreads: totalThreads,
      unreadThreads: unreadThreads,
      myRights: myRights,
      isSubscribed: isSubscribed,
      selectMode: selectMode
    );
  }
}