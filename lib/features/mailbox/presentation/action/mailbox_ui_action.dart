
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

class MailboxUIAction extends UIAction {
  static final idle = MailboxUIAction();

  MailboxUIAction() : super();

  @override
  List<Object?> get props => [];
}

class SelectMailboxDefaultAction extends MailboxUIAction {}

class RefreshChangeMailboxAction extends MailboxUIAction {
  final jmap.State newState;

  RefreshChangeMailboxAction({required this.newState});

  @override
  List<Object?> get props => [newState];
}

class OpenMailboxAction extends MailboxUIAction {

  final PresentationMailbox presentationMailbox;

  OpenMailboxAction(this.presentationMailbox);

  @override
  List<Object?> get props => [presentationMailbox];
}

class SystemBackToInboxAction extends MailboxUIAction {}

class RefreshAllMailboxAction extends MailboxUIAction {}