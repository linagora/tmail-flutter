
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/filter_message_option.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class DashBoardAction extends UIAction {
  static final idle = DashBoardAction();

  DashBoardAction() : super();

  @override
  List<Object?> get props => [];
}

class ComposeEmailAction extends DashBoardAction {

  RouterArguments? arguments;

  ComposeEmailAction({this.arguments});

  @override
  List<Object?> get props => [arguments];
}

class CloseComposeEmailAction extends DashBoardAction {

  CloseComposeEmailAction();

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

class MarkAsReadAllEmailAction extends DashBoardAction {

  MarkAsReadAllEmailAction();

  @override
  List<Object?> get props => [];
}

class FilterMessageAction extends DashBoardAction {

  BuildContext context;
  FilterMessageOption option;

  FilterMessageAction(this.context, this.option);

  @override
  List<Object?> get props => [option];
}

class HandleEmailActionTypeAction extends DashBoardAction {

  BuildContext context;
  EmailActionType emailAction;
  List<PresentationEmail> listEmailSelected;

  HandleEmailActionTypeAction(this.context, this.listEmailSelected, this.emailAction);

  @override
  List<Object> get props => [listEmailSelected, emailAction];
}

class GoToSettingsAction extends DashBoardAction {

  GoToSettingsAction();

  @override
  List<Object?> get props => [];
}