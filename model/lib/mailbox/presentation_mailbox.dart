import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:model/mailbox/select_mode.dart';

class PresentationMailbox with EquatableMixin {

  static final roleTrash = Role('trash');
  static final roleSent = Role('sent');
  static final roleTemplates = Role('templates');

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
      this.selectMode = SelectMode.INACTIVE
    }
  );

  bool hasParentId() => parentId != null && parentId!.id.value.isNotEmpty;

  bool hasRole() => role != null && role!.value.isNotEmpty;

  String getCountUnReadEmails() {
    if (role == roleTrash || role == roleSent || role == roleTemplates) {
      return '';
    }

    if (unreadEmails == null || unreadEmails!.value.value <= 0) {
      return '';
    }

    return unreadEmails!.value.value <= 999 ? '${unreadEmails!.value.value}' : '999+';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    parentId,
    role
  ];
}