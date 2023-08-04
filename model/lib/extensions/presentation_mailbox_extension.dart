import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  bool get isActivated => state == MailboxState.activated;

  bool hasParentId() => parentId != null && parentId!.id.value.isNotEmpty;

  bool hasRole() => role != null && role!.value.isNotEmpty;

  bool get isDefault => hasRole();

  bool get isPersonal => namespace == null || namespace == Namespace('Personal');

  bool get isTeamMailboxes => !isPersonal && !hasParentId();

  bool get isChildOfTeamMailboxes => !isPersonal && hasParentId();

  String get countUnReadEmailsAsString {
    if (countUnreadEmails <= 0) return '';
    return countUnreadEmails <= 999 ? '$countUnreadEmails' : '999+';
  }

  int get countUnreadEmails => unreadEmails?.value.value.toInt() ?? 0;

  int get countTotalEmails => totalEmails?.value.value.toInt() ?? 0;

  bool get isSpam => role == PresentationMailbox.roleSpam;

  bool get isTrash => role == PresentationMailbox.roleTrash;

  bool get isDrafts => role == PresentationMailbox.roleDrafts;

  bool get isTemplates => role == PresentationMailbox.roleTemplates;

  bool get isSent => role == PresentationMailbox.roleSent;

  bool get isOutbox => name == PresentationMailbox.lowerCaseOutboxMailboxName || role == PresentationMailbox.roleOutbox;

  bool get isSubscribedMailbox => isSubscribed != null && isSubscribed?.value == true;

  bool get allowedToDisplayCountOfUnreadEmails => !(isTrash || isSpam || isDrafts || isTemplates || isSent);

  bool get allowedToDisplayCountOfTotalEmails => isTrash || isSpam;

  String get countTotalEmailsAsString {
    if (countTotalEmails <= 0) return '';
    return countTotalEmails <= 999 ? '$countTotalEmails' : '999+';
  }

  String? get emailTeamMailBoxes => namespace?.value.substring(
    (namespace?.value.indexOf('[') ?? 0) + 1,
    namespace?.value.indexOf(']'));

  bool get allowedToDisplay => isSubscribedMailbox || isDefault;

  MailboxId? get mailboxId {
    if (id == PresentationMailbox.unifiedMailbox.id) {
      return null;
    } else {
      return id;
    }
  }

  bool get pushNotificationDeactivated => isOutbox || isSent || isDrafts || isTrash || isSpam;

  PresentationMailbox toPresentationMailboxWithMailboxPath(String mailboxPath) {
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
      selectMode: selectMode,
      mailboxPath: mailboxPath,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox withDisplayName(String? displayName) {
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
      selectMode: selectMode,
      mailboxPath: mailboxPath,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox withMailboxSate(MailboxState newMailboxState) {
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
      selectMode: selectMode,
      mailboxPath: mailboxPath,
      state: newMailboxState,
      namespace: namespace,
      displayName: displayName,
    );
  }

  Mailbox toMailbox() {
    return Mailbox(
      id: id,
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
      namespace: namespace,
    );
  }

  PresentationMailbox toggleSelectPresentationMailbox() {
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
      mailboxPath: mailboxPath,
      selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox toSelectedPresentationMailbox({required SelectMode selectMode}) {
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
      mailboxPath: mailboxPath,
      selectMode: selectMode,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }
}