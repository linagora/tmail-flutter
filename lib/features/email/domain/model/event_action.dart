
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EventActionType {
  yes,
  maybe,
  no,
  mailToAttendees;

  String getLabelButton(BuildContext context) {
    switch(this) {
      case EventActionType.yes:
        return AppLocalizations.of(context).yes;
      case EventActionType.maybe:
        return AppLocalizations.of(context).maybe;
      case EventActionType.no:
        return AppLocalizations.of(context).no;
      case EventActionType.mailToAttendees:
        return AppLocalizations.of(context).mailToAttendees;
    }
  }

  String getToastMessageSuccess(BuildContext context) {
    switch(this) {
      case EventActionType.yes:
        return AppLocalizations.of(context).youWillAttendThisMeeting;
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