
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EventActionType {
  yes,
  acceptCounter,
  maybe,
  no,
  mailToAttendees;

  String getLabelButton(AppLocalizations appLocalizations) {
    switch(this) {
      case EventActionType.yes:
      case EventActionType.acceptCounter:
        return appLocalizations.yes;
      case EventActionType.maybe:
        return appLocalizations.maybe;
      case EventActionType.no:
        return appLocalizations.no;
      case EventActionType.mailToAttendees:
        return appLocalizations.mailToAttendees;
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
