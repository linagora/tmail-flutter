import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension ListPresentationMailboxExtension on List<PresentationMailbox> {

  /// The primary-account sidebar filter: subscribed mailboxes plus the system
  /// (role) mailboxes, which stay visible even when unsubscribed so the user
  /// always sees their own Inbox, Sent, Trash and so on.
  List<PresentationMailbox> get listSubscribedMailboxesAndDefaultMailboxes =>
    where((mailbox) => mailbox.isSubscribedMailbox || mailbox.isDefault).toList();

  /// The sidebar filter for another user's (delegated) account: strictly the
  /// subscribed mailboxes, with no `isDefault` override.
  ///
  /// RFC 8621 section 2 on `isSubscribed`: "This SHOULD default to false for
  /// Mailboxes in shared accounts the user has access to". The user curates
  /// exactly which delegated folders appear by (un)subscribing to them from the
  /// Mailbox visibility settings screen (which loads the full unfiltered list).
  /// Unlike [listSubscribedMailboxesAndDefaultMailboxes] the delegated Inbox,
  /// Sent and Trash are NOT pinned visible, so unsubscribing any of them hides
  /// it as expected.
  List<PresentationMailbox> get listSubscribedMailboxes =>
    where((mailbox) => mailbox.isSubscribedMailbox).toList();

  /// Mailboxes the user can actually read. A delegated account with none of
  /// these is a "ghost" (listed in the JMAP session with no usable ACLs) and is
  /// dropped entirely. `myRights == null` is treated as readable, since not
  /// every backend returns the property.
  List<PresentationMailbox> get listReadableMailboxes =>
    where((mailbox) => mailbox.myRights?.mayReadItems != false).toList();

  List<PresentationMailbox> get listPersonalMailboxes =>
    where((mailbox) => mailbox.isPersonal).toList();

  /// Mailboxes a user can pick as a destination or open from search.
  ///
  /// Unlike [listPersonalMailboxes] this keeps mailboxes from other users'
  /// accounts, which are never `isPersonal`. A synthetic account root is a
  /// UI-only grouping node with no server-side mailbox, so it is never a valid
  /// pick even though it satisfies the shared-account condition.
  List<PresentationMailbox> get listSelectableMailboxes =>
    where((mailbox) =>
      !mailbox.isVirtualFolder &&
      !mailbox.isSharedAccountRoot &&
      (mailbox.isPersonal || mailbox.isSharedAccount)).toList();

  bool get isAllPersonalMailboxes => every((mailbox) => mailbox.isPersonal && !mailbox.isDefault);

  bool get isAllDefaultMailboxes => every((mailbox) => mailbox.isDefault);

  bool get isAllUnreadMailboxes => every((mailbox) => mailbox.countUnReadEmailsAsString.isNotEmpty);

  List<MailboxId> get mailboxIds => map((mailbox) => mailbox.id).toList();

  List<PresentationMailbox> get withoutVirtualMailbox =>
      whereNot((mailbox) => mailbox.isVirtualFolder).toList();
}