
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class DashBoardAction extends UIAction {
  static final idle = DashBoardAction();

  DashBoardAction() : super();

  @override
  List<Object?> get props => [];
}

class RefreshAllEmailAction extends DashBoardAction {

  RefreshAllEmailAction();

  @override
  List<Object?> get props => [];
}

class SelectionAllEmailAction extends DashBoardAction {

  SelectionAllEmailAction();

  @override
  List<Object?> get props => [];
}

class CancelSelectionAllEmailAction extends DashBoardAction {

  CancelSelectionAllEmailAction();

  @override
  List<Object?> get props => [];
}

class FilterMessageAction extends DashBoardAction {

  final BuildContext context;
  final FilterMessageOption option;

  FilterMessageAction(this.context, this.option);

  @override
  List<Object?> get props => [option];
}

class HandleEmailActionTypeAction extends DashBoardAction {

  final BuildContext context;
  final EmailActionType emailAction;
  final List<PresentationEmail> listEmailSelected;

  HandleEmailActionTypeAction(this.context, this.listEmailSelected, this.emailAction);

  @override
  List<Object> get props => [listEmailSelected, emailAction];
}

class OpenEmailDetailedFromSuggestionQuickSearchAction extends DashBoardAction {

  final BuildContext context;
  final PresentationEmail presentationEmail;

  OpenEmailDetailedFromSuggestionQuickSearchAction(this.context, this.presentationEmail);

  @override
  List<Object?> get props => [presentationEmail];
}

class StartSearchEmailAction extends DashBoardAction {

  StartSearchEmailAction();

  @override
  List<Object?> get props => [];
}

class EmptyTrashAction extends DashBoardAction {

  final BuildContext context;

  EmptyTrashAction(this.context);

  @override
  List<Object?> get props => [];
}

class ClearSearchEmailAction extends DashBoardAction {
  ClearSearchEmailAction();

  @override
  List<Object?> get props => [];
}

class ClearAllFieldOfAdvancedSearchAction extends DashBoardAction {
  ClearAllFieldOfAdvancedSearchAction();

  @override
  List<Object?> get props => [];
}

class SelectMailboxDefaultAction extends DashBoardAction {
  SelectMailboxDefaultAction();

  @override
  List<Object?> get props => [];
}

class SelectEmailByIdAction extends DashBoardAction {

  final EmailId emailId;

  SelectEmailByIdAction(this.emailId);

  @override
  List<Object?> get props => [emailId];
}