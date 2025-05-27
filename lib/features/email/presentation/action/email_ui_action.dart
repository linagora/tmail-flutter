
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
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
  final jmap.State? newState;

  RefreshChangeEmailAction(this.newState);

  @override
  List<Object?> get props => [newState];
}

class CloseEmailDetailedViewToRedirectToTheInboxAction extends EmailUIAction {}

class CloseEmailDetailedViewAction extends EmailUIAction {}

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