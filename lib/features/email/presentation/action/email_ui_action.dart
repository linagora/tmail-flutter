
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';

class EmailUIAction extends UIAction {
  static final idle = EmailUIAction();

  EmailUIAction() : super();

  @override
  List<Object?> get props => [];
}

class RefreshChangeEmailAction extends EmailUIAction {
  final jmap.State newState;

  RefreshChangeEmailAction({required this.newState});

  @override
  List<Object?> get props => [newState];
}

class HideEmailContentViewAction extends EmailUIAction {}

class ShowEmailContentViewAction extends EmailUIAction {}

class RefreshAllEmailAction extends EmailUIAction {}

class CloseEmailInThreadDetailAction extends EmailUIAction {}

class PerformEmailActionInThreadDetailAction extends EmailUIAction {
  PerformEmailActionInThreadDetailAction({
    required this.emailActionType,
    required this.presentationEmail,
  });

  final EmailActionType emailActionType;
  final PresentationEmail presentationEmail;

  @override
  List<Object?> get props => [
    emailActionType,
    presentationEmail,
  ];
}

class RefreshThreadDetailAction extends EmailUIAction {
  RefreshThreadDetailAction(this.emailChangeResponse);

  final EmailChangeResponse emailChangeResponse;

  @override
  List<Object?> get props => [emailChangeResponse];
}

class DisposePreviousExpandedEmailAction extends EmailUIAction {
  DisposePreviousExpandedEmailAction(this.emailId);

  final EmailId emailId;

  @override
  List<Object?> get props => [emailId];
}

class UnsubscribeFromThreadAction extends EmailUIAction {
  UnsubscribeFromThreadAction(this.emailId, this.listUnsubscribe);

  final EmailId emailId;
  final String listUnsubscribe;

  @override
  List<Object?> get props => [emailId, listUnsubscribe];
}

class CollapseEmailInThreadDetailAction extends EmailUIAction {
  CollapseEmailInThreadDetailAction(this.emailId);

  final EmailId emailId;

  @override
  List<Object?> get props => [emailId];
}

class OpenAttachmentListAction extends EmailUIAction {
  OpenAttachmentListAction({
    required this.emailId,
    required this.countAttachments,
    required this.screenHeight,
    this.isDisplayAllAttachments = false,
  });

  final EmailId? emailId;
  final int countAttachments;
  final bool isDisplayAllAttachments;
  final double screenHeight;

  @override
  List<Object?> get props => [
    emailId,
    countAttachments,
    isDisplayAllAttachments,
    screenHeight,
  ];
}

class TriggerMailViewKeyboardShortcutAction extends EmailUIAction {
  TriggerMailViewKeyboardShortcutAction(this.actionType, this.email);

  final EmailActionType actionType;
  final PresentationEmail email;

  @override
  List<Object?> get props => [actionType, email];
}

class RemoveLabelFromEmailAction extends EmailUIAction {
  RemoveLabelFromEmailAction(this.emailId, this.label);

  final EmailId emailId;
  final Label label;

  @override
  List<Object?> get props => [emailId, label];
}
