
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';

class DashBoardAction extends UIAction {
  static final idle = DashBoardAction();

  DashBoardAction() : super();

  @override
  List<Object?> get props => [];
}

class RefreshAllEmailAction extends DashBoardAction {}

class SelectionAllEmailAction extends DashBoardAction {}

class CancelSelectionAllEmailAction extends DashBoardAction {}

class FilterMessageAction extends DashBoardAction {

  final BuildContext context;
  final FilterMessageOption option;

  FilterMessageAction(this.context, this.option);

  @override
  List<Object?> get props => [context, option];
}

class HandleEmailActionTypeAction extends DashBoardAction {

  final BuildContext context;
  final EmailActionType emailAction;
  final List<PresentationEmail> listEmailSelected;

  HandleEmailActionTypeAction(this.context, this.listEmailSelected, this.emailAction);

  @override
  List<Object> get props => [context, listEmailSelected, emailAction];
}

class OpenEmailDetailedFromSuggestionQuickSearchAction extends DashBoardAction {

  final BuildContext context;
  final PresentationEmail presentationEmail;

  OpenEmailDetailedFromSuggestionQuickSearchAction(this.context, this.presentationEmail);

  @override
  List<Object?> get props => [context, presentationEmail];
}

class StartSearchEmailAction extends DashBoardAction {
  final QuickSearchFilter? filter;

  StartSearchEmailAction({this.filter});

  @override
  List<Object?> get props => [filter];
}

class EmptyTrashAction extends DashBoardAction {

  final BuildContext context;

  EmptyTrashAction(this.context);

  @override
  List<Object?> get props => [context];
}

class ClearSearchEmailAction extends DashBoardAction {}

class ClearAllFieldOfAdvancedSearchAction extends DashBoardAction {}

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