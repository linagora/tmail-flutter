
enum EmailActionType {
  reply(1),
  replyToList(1),
  forward(1),
  replyAll(1),
  compose(),
  markAsRead(2),
  markAsUnread(2),
  markAsStarred(2),
  unMarkAsStarred(2),
  moveToMailbox(2),
  editDraft(),
  editSendingEmail(),
  composeFromContentShared(),
  composeFromFileShared(),
  composeFromEmailAddress(),
  composeFromMailtoUri(),
  editAsNewEmail(4),
  composeFromLocalEmailDraft(),
  moveToTrash(3),
  deletePermanently(3),
  preview(),
  selection(),
  moveToSpam(2),
  unSpam(),
  openInNewTab(1),
  createRule(4),
  unsubscribe(),
  composeFromUnsubscribeMailtoLink(),
  archiveMessage(3),
  printAll(4),
  downloadMessageAsEML(4);

  /// Add category to group email action
  final int category;

  const EmailActionType([this.category = -1]);
}