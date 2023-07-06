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
  static const String spamRole = 'spam';
  static const String archiveRole = 'archive';

  static final PresentationMailbox unifiedMailbox = PresentationMailbox(MailboxId(Id('unified')));

  static final roleInbox = Role(inboxRole);
  static final roleTrash = Role(trashRole);
  static final roleSent = Role(sentRole);
  static final roleTemplates = Role(templatesRole);
  static final roleOutbox = Role(outboxRole);
  static final roleDrafts = Role(draftsRole);
  static final roleSpam = Role(spamRole);

  static final outboxMailboxName = MailboxName('Outbox');
  static final lowerCaseOutboxMailboxName = MailboxName('outbox');

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

  bool get isActivated => state == MailboxState.activated;

  bool hasParentId() => parentId != null && parentId!.id.value.isNotEmpty;

  bool hasRole() => role != null && role!.value.isNotEmpty;

  bool get isDefault => hasRole();

  bool get isPersonal => namespace == null || namespace == Namespace('Personal');

  bool get isTeamMailboxes => !isPersonal && !hasParentId();

  bool get isChildOfTeamMailboxes => !isPersonal && hasParentId();

  String getCountUnReadEmails() {
    if (unreadEmails == null || unreadEmails!.value.value <= 0) {
      return '';
    }

    return unreadEmails!.value.value <= 999 ? '${unreadEmails!.value.value}' : '999+';
  }

  int get countEmails => totalEmails?.value.value.toInt() ?? 0;

  bool get isSpam => role == roleSpam;
  
  bool get isTrash => role == roleTrash;

  bool get isDrafts => role == roleDrafts;

  bool get isTemplates => role == roleTemplates;

  bool get isSent => role == roleSent;

  bool get isOutbox => name == lowerCaseOutboxMailboxName || role == roleOutbox;

  bool get isSubscribedMailbox => isSubscribed != null && isSubscribed?.value == true;

  bool matchCountingRules() {
    if (isTrash || isDrafts || isTemplates || isSent) {
      return false;
    } else {
      return true;
    }
  }

  String? get emailTeamMailBoxes => namespace?.value.substring(
    (namespace?.value.indexOf('[') ?? 0) + 1,
    namespace?.value.indexOf(']'));

  bool get allowedToDisplay => isSubscribedMailbox || isDefault;

  MailboxId? get mailboxId {
    if (id == unifiedMailbox.id) {
      return null;
    } else {
      return id;
    }
  }

  bool get pushNotificationDeactivated => isOutbox || isSent || isDrafts || isTrash || isSpam;

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
  ];
}