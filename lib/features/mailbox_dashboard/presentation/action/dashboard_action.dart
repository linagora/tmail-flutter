
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class DashBoardAction extends UIAction {
  static final idle = DashBoardAction();

  DashBoardAction() : super();

  @override
  List<Object?> get props => [];
}

class SelectionAllEmailAction extends DashBoardAction {}

class CancelSelectionAllEmailAction extends DashBoardAction {}

class FilterMessageAction extends DashBoardAction {

  final FilterMessageOption option;

  FilterMessageAction(this.option);

  @override
  List<Object?> get props => [option];
}

class HandleEmailActionTypeAction extends DashBoardAction {

  final EmailActionType emailAction;
  final List<PresentationEmail> listEmailSelected;

  HandleEmailActionTypeAction(this.listEmailSelected, this.emailAction);

  @override
  List<Object> get props => [listEmailSelected, emailAction];
}

class OpenEmailDetailedFromSuggestionQuickSearchAction extends DashBoardAction {

  final PresentationEmail presentationEmail;

  OpenEmailDetailedFromSuggestionQuickSearchAction(this.presentationEmail);

  @override
  List<Object?> get props => [presentationEmail];
}

class StartSearchEmailAction extends DashBoardAction {}

class EmptyTrashAction extends DashBoardAction {}

class ClearSearchEmailAction extends DashBoardAction {}

class ClearAllFieldOfAdvancedSearchAction extends DashBoardAction {}

class OpenEmailInsideMailboxFromLocationBar extends DashBoardAction {

  final EmailId emailId;
  final PresentationMailbox presentationMailbox;

  OpenEmailInsideMailboxFromLocationBar(this.emailId, this.presentationMailbox);

  @override
  List<Object?> get props => [emailId, presentationMailbox];
}

class OpenEmailWithoutMailboxFromLocationBar extends DashBoardAction {

  final EmailId emailId;

  OpenEmailWithoutMailboxFromLocationBar(this.emailId);

  @override
  List<Object?> get props => [emailId];
}

class OpenEmailSearchedFromLocationBar extends DashBoardAction {

  final EmailId emailId;
  final SearchQuery? searchQuery;

  OpenEmailSearchedFromLocationBar(
    this.emailId,
    {
      this.searchQuery,
    }
  );

  @override
  List<Object?> get props => [emailId, searchQuery];
}

class SearchEmailFromLocationBar extends DashBoardAction {

  final SearchQuery searchQuery;

  SearchEmailFromLocationBar(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
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

class QuickSearchEmailByFromAction extends DashBoardAction {

  final EmailAddress emailAddress;

  QuickSearchEmailByFromAction(this.emailAddress);

  @override
  List<Object?> get props => [emailAddress];
}

class CloseSearchEmailViewAction extends DashBoardAction {}

class CancelSelectionSearchEmailAction extends DashBoardAction {}

class OpenAdvancedSearchViewAction extends DashBoardAction {}

class ClearSearchFilterAppliedAction extends DashBoardAction {}

class ClearAdvancedSearchFilterEmailAction extends DashBoardAction {}

class MoreSelectedEmailAction extends DashBoardAction {

  final BuildContext context;
  final RelativeRect position;

  MoreSelectedEmailAction(this.context, this.position);

  @override
  List<Object> get props => [context, position];
}