
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EventActionType {
  yes,
  maybe,
  no;

  String getLabelButton(BuildContext context) {
    switch(this) {
      case EventActionType.yes:
        return AppLocalizations.of(context).yes;
      case EventActionType.maybe:
        return AppLocalizations.of(context).maybe;
      case EventActionType.no:
        return AppLocalizations.of(context).no;
    }
  }
}

class EventAction with EquatableMixin {
  final EventActionType actionType;
  final String link;

  EventAction(this.actionType, this.link);

  @override
  List<Object?> get props => [actionType, link];
}