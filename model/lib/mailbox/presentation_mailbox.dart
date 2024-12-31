import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/select_mode.dart';

class PresentationMailbox with EquatableMixin {

  static const String inboxRole = 'inbox';
  static const String sentRole = 'sent';
  static const String trashRole = 'trash';
  static const String templatesRole= 'templates';
  static const String outboxRole = 'outbox';
  static const String draftsRole = 'drafts';
  static const String junkRole = 'junk';
  static const String spamRole = 'spam';
  static const String archiveRole = 'archive';
  static const String recoveredRole = 'restored messages';

  static final PresentationMailbox unifiedMailbox = PresentationMailbox(MailboxId(Id('unified')));

  static final roleInbox = Role(inboxRole);
  static final roleTrash = Role(trashRole);
  static final roleSent = Role(sentRole);
  static final roleTemplates = Role(templatesRole);
  static final roleOutbox = Role(outboxRole);
  static final roleDrafts = Role(draftsRole);
  static final roleSpam = Role(spamRole);
  static final roleJunk = Role(junkRole);
  static final roleArchive = Role(archiveRole);
  static final roleRecovered = Role(recoveredRole);

  final MailboxId id;
  final MailboxName? name;
  final MailboxId? parentId;
  final Role? role;
  final SortOrder? sortOrder;
  final TotalEmails? totalEmails;
  final UnreadEmails? unreadEmails;
  final TotalThreads? totalThreads;
  final UnreadThreads? unreadThreads;
  final MailboxRights? myRights;
  final IsSubscribed? isSubscribed;
  final SelectMode selectMode;
  final String? mailboxPath;
  final MailboxState? state;
  final Namespace? namespace;
  final String? displayName;

  PresentationMailbox(
    this.id,
    {
      this.name,
      this.parentId,
      this.role,
      this.sortOrder,
      this.totalEmails,
      this.unreadEmails,
      this.totalThreads,
      this.unreadThreads,
      this.myRights,
      this.isSubscribed,
      this.selectMode = SelectMode.INACTIVE,
      this.mailboxPath,
      this.state = MailboxState.activated,
      this.namespace,
      this.displayName,
    }
  );

  @override
  List<Object?> get props => [
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
    selectMode,
    mailboxPath,
    state,
    namespace,
    displayName,
  ];

  PresentationMailbox copyWith({
    MailboxId? id,
    MailboxName? name,
    MailboxId? parentId,
    Role? role,
    SortOrder? sortOrder,
    TotalEmails? totalEmails,
    UnreadEmails? unreadEmails,
    TotalThreads? totalThreads,
    UnreadThreads? unreadThreads,
    MailboxRights? myRights,
    IsSubscribed? isSubscribed,
    SelectMode? selectMode,
    String? mailboxPath,
    MailboxState? state,
    Namespace? namespace,
    String? displayName,
  }) {
    return PresentationMailbox(
      id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      role: role ?? this.role,
      sortOrder: sortOrder ?? this.sortOrder,
      totalEmails: totalEmails ?? this.totalEmails,
      unreadEmails: unreadEmails ?? this.unreadEmails,
      totalThreads: totalThreads ?? this.totalThreads,
      unreadThreads: unreadThreads ?? this.unreadThreads,
      myRights: myRights ?? this.myRights,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      selectMode: selectMode ?? this.selectMode,
      mailboxPath: mailboxPath ?? this.mailboxPath,
      state: state ?? this.state,
      namespace: namespace ?? this.namespace,
      displayName: displayName ?? this.displayName,
    );
  }
}