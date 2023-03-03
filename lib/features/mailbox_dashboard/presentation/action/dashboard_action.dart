
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';

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

class SelectEmailByIdAction extends DashBoardAction {

  final NavigationRouter navigationRouter;

  SelectEmailByIdAction(this.navigationRouter);

  @override
  List<Object?> get props => [navigationRouter];
}

class SearchEmailByQueryAction extends DashBoardAction {

  final NavigationRouter navigationRouter;

  SearchEmailByQueryAction(this.navigationRouter);

  @override
  List<Object?> get props => [navigationRouter];
}
class OpenMailboxAction extends DashBoardAction {

  final BuildContext context;
  final PresentationMailbox presentationMailbox;

  OpenMailboxAction(this.context, this.presentationMailbox);

  @override
  List<Object?> get props => [context, presentationMailbox];
}

class SelectDateRangeToAdvancedSearch extends DashBoardAction {

  final DateTime? startDate;
  final DateTime? endDate;

  SelectDateRangeToAdvancedSearch(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

class ClearDateRangeToAdvancedSearch extends DashBoardAction {

  final EmailReceiveTimeType receiveTime;

  ClearDateRangeToAdvancedSearch(this.receiveTime);

  @override
  List<Object?> get props => [receiveTime];
}