import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/mailbox_constants.dart';
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

  bool get isInbox => role == PresentationMailbox.roleInbox;

  bool get isSpam => role == PresentationMailbox.roleSpam || role == PresentationMailbox.roleJunk;

  bool get isTrash => role == PresentationMailbox.roleTrash;

  bool get isDrafts => role == PresentationMailbox.roleDrafts;

  bool get isTemplates => role == PresentationMailbox.roleTemplates;

  bool get isSent => role == PresentationMailbox.roleSent;

  bool get isOutbox => name?.name == PresentationMailbox.outboxRole || role == PresentationMailbox.roleOutbox;

  bool get isArchive => role == PresentationMailbox.roleArchive;

  bool get isRecovered => role == PresentationMailbox.roleRecovered;

  bool get isSubscribedMailbox => isSubscribed != null && isSubscribed?.value == true;

  bool get isSubaddressingAllowed => rights != null && rights?[anyoneIdentifier]?.contains(postingRight) == true;

  bool get allowedToDisplayCountOfUnreadEmails => !(isTrash || isSpam || isDrafts || isTemplates || isSent) && countUnreadEmails > 0;

  bool get allowedToDisplayCountOfTotalEmails => (isTrash || isSpam || isDrafts) && countTotalEmails > 0;

  bool get allowedHasEmptyAction => (isTrash || isSpam) && countTotalEmails > 0;

  String get countTotalEmailsAsString {
    if (countTotalEmails <= 0) return '';
    return countTotalEmails <= 999 ? '$countTotalEmails' : '999+';
  }

  String get emailTeamMailBoxes {
    final name = namespace?.value ?? '';
    if (name.isNotEmpty == true &&
        name.indexOf('[') > 0 &&
        name.indexOf(']') > name.indexOf('[')) {
      return name.substring(name.indexOf('[') + 1, name.indexOf(']'));
    }
    return name;
  }

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
      rights: rights
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
      rights: rights
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
      rights: rights
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
      rights: rights
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
      rights: rights
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
      rights: rights
    );
  }
}