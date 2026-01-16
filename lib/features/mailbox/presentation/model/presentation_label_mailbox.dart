import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

class PresentationLabelMailbox extends PresentationMailbox {
  final Label label;

  PresentationLabelMailbox(
    super.id,
    this.label, {
    super.name,
    super.parentId,
    super.role,
    super.sortOrder,
    super.totalEmails,
    super.unreadEmails,
    super.totalThreads,
    super.unreadThreads,
    super.myRights,
    super.isSubscribed,
    super.selectMode = SelectMode.INACTIVE,
    super.mailboxPath,
    super.state = MailboxState.activated,
    super.namespace,
    super.displayName,
    super.rights,
  });

  factory PresentationLabelMailbox.initial(Label label) {
    return PresentationLabelMailbox(MailboxId(label.id!), label);
  }

  @override
  List<Object?> get props => [label, ...super.props];
}
