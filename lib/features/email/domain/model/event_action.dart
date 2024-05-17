
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
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

  PatchObject generateEventAttendanceStatusActionPath() {
    switch(this) {
      case EventActionType.yes:
        return PatchObject({
          KeyWordIdentifierExtension.acceptedEventAttendance.generatePath(): true,
          KeyWordIdentifierExtension.tentativelyAcceptedEventAttendance.generatePath(): null,
          KeyWordIdentifierExtension.rejectedEventAttendance.generatePath(): null,
        });
      case EventActionType.maybe:
        return PatchObject({
          KeyWordIdentifierExtension.acceptedEventAttendance.generatePath(): null,
          KeyWordIdentifierExtension.tentativelyAcceptedEventAttendance.generatePath(): true,
          KeyWordIdentifierExtension.rejectedEventAttendance.generatePath(): null,
        });
      case EventActionType.no:
        return PatchObject({
          KeyWordIdentifierExtension.acceptedEventAttendance.generatePath(): null,
          KeyWordIdentifierExtension.tentativelyAcceptedEventAttendance.generatePath(): null,
          KeyWordIdentifierExtension.rejectedEventAttendance.generatePath(): true,
        });
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