
enum EmailActionType {
  reply(1),
  replyToList(1),
  forward(1),
  replyAll(1),
  labelAs(3),
  compose(),
  markAsRead(3),
  markAsUnread(3),
  markAsStarred(3),
  unMarkAsStarred(3),
  moveToMailbox(3),
  editDraft(),
  editSendingEmail(),
  composeFromContentShared(),
  composeFromFileShared(),
  composeFromEmailAddress(),
  composeFromMailtoUri(),
  editAsNewEmail(4),
  reopenComposerBrowser(),
  moveToTrash(2),
  deletePermanently(2),
  preview(),
  selection(),
  moveToSpam(3),
  unSpam(),
  openInNewTab(1),
  createRule(4),
  unsubscribe(),
  composeFromUnsubscribeMailtoLink(),
  archiveMessage(2),
  printAll(4),
  downloadMessageAsEML(4),
  restoreComposerFromPersistentCache();

  /// Add category to group email action
  final int category;

  const EmailActionType([this.category = -1]);
}