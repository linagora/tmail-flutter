
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EventActionType {
  yes,
  acceptCounter,
  maybe,
  no,
  mailToAttendees;

  String getLabelButton(BuildContext context) {
    switch(this) {
      case EventActionType.yes:
      case EventActionType.acceptCounter:
        return AppLocalizations.of(context).yes;
      case EventActionType.maybe:
        return AppLocalizations.of(context).maybe;
      case EventActionType.no:
        return AppLocalizations.of(context).no;
      case EventActionType.mailToAttendees:
        return AppLocalizations.of(context).mailToAttendees;
    }
  }

  Key getKeyButton() {
    switch (this) {
      case EventActionType.yes:
        return const Key('yes_event_action_button');
      case EventActionType.acceptCounter:
        return const Key('acceptCounter_event_action_button');
      case EventActionType.maybe:
        return const Key('maybe_event_action_button');
      case EventActionType.no:
        return const Key('no_event_action_button');
      case EventActionType.mailToAttendees:
        return const Key('mailToAttendees_event_action_button');
    }
  }

  String getToastMessageSuccess(BuildContext context) {
    switch(this) {
      case EventActionType.yes:
        return AppLocalizations.of(context).youWillAttendThisMeeting;
      case EventActionType.acceptCounter:
        return AppLocalizations.of(context).youAcceptedTheProposedTimeForThisMeeting;
      case EventActionType.maybe:
        return AppLocalizations.of(context).youMayAttendThisMeeting;
      case EventActionType.no:
        return AppLocalizations.of(context).youWillNotAttendThisMeeting;
      case EventActionType.mailToAttendees:
        return '';
    }
  }
}

class EventAction with EquatableMixin {
  final EventActionType actionType;
  final String link;

  EventAction(this.actionType, this.link);

  factory EventAction.mailToAttendees() {
    return EventAction(EventActionType.mailToAttendees, '');
  }

  @override
  List<Object?> get props => [actionType, link];
}
