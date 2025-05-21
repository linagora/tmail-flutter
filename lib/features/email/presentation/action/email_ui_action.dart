
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

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

class CloseEmailInThreadDetailAction extends EmailUIAction {
  final EmailId emailId;

  CloseEmailInThreadDetailAction(this.emailId);

  @override
  List<Object?> get props => [emailId];
}