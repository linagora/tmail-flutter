
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/actions/app_action.dart';

class MarkAsEmailReadAction extends ActionOffline {
  final EmailId emailId;
  final PresentationMailbox presentationMailbox;

  MarkAsEmailReadAction(this.emailId, this.presentationMailbox);

  @override
  List<Object?> get props => [emailId, presentationMailbox];
}

class MarkAsMultipleEmailReadAndUnreadAction extends ActionOffline {
  final List<EmailId> listEmailId;
  final PresentationMailbox presentationMailbox;
  final bool isUnread;

  MarkAsMultipleEmailReadAndUnreadAction(this.listEmailId, this.presentationMailbox, this.isUnread);

  @override
  List<Object?> get props => [listEmailId, presentationMailbox, isUnread];
}