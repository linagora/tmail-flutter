
import 'package:flutter/cupertino.dart';
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

class OpenEmailDetailedAction extends DashBoardAction {

  final BuildContext context;
  final PresentationEmail presentationEmail;

  OpenEmailDetailedAction(this.context, this.presentationEmail);

  @override
  List<Object?> get props => [presentationEmail];
}

class DisableSearchEmailAction extends DashBoardAction {

  DisableSearchEmailAction();

  @override
  List<Object?> get props => [];
}