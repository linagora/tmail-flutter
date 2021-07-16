import 'package:equatable/equatable.dart';
import 'package:model/mailbox/mailbox_properties.dart';
import 'package:model/mailbox/mailbox_rights.dart';
import 'package:model/mailbox/select_mode.dart';

class Mailbox with EquatableMixin {

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
  final MailboxName? qualifiedName;

  Mailbox(
    this.id,
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
    {
      this.qualifiedName,
      this.selectMode = SelectMode.INACTIVE
    }
  );

  bool hasParentId() => parentId != null && parentId!.id.value.isNotEmpty;

  bool isMailboxRole() => role != null && role!.value.isNotEmpty;

  String getNameMailbox() => name == null ? '' : name!.name;

  String getQualifiedName() => qualifiedName == null ? getNameMailbox() : qualifiedName!.name;

  String getCountUnReadEmails() {
    if (unreadEmails == null) {
      return '';
    } else {
      if (unreadEmails!.value.value <= 0) {
        return '';
      } else {
        return unreadEmails!.value.value <= 999
          ? '${unreadEmails!.value.value}'
          : '999+';
      }
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    qualifiedName,
    parentId,
    role
  ];
}