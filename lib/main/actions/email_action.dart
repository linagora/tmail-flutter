
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/actions/app_action.dart';

class MarkAsEmailReadAction extends ActionOnline {
  final EmailId emailId;
  final PresentationMailbox presentationMailbox;

  MarkAsEmailReadAction(this.emailId, this.presentationMailbox);

  @override
  List<Object?> get props => [emailId, presentationMailbox];
}