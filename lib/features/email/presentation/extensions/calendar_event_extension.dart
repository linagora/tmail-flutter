
import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_participation_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension CalendarEventExtension on CalendarEvent {

  Color getColorEventActionBanner(String senderEmailAddress) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return AppColor.colorInvitedEventActionText;
      case EventMethod.refresh:
      case EventMethod.counter:
        return AppColor.colorUpdatedEventActionText;
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return AppColor.colorCanceledEventActionText;
      case EventMethod.reply:
        final matchedAttendee = findAttendeeHasUpdatedStatus(senderEmailAddress);
        if (matchedAttendee != null) {
          return getAttendeeMessageTextColor(matchedAttendee.participationStatus);
        } else {
          return Colors.transparent;
        }
      default:
        return Colors.transparent;
    }
  }

  Color getColorEventActionText(String senderEmailAddress) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return AppColor.colorInvitedEventActionText;
      case EventMethod.refresh:
      case EventMethod.counter:
        return AppColor.colorUpdatedEventActionText;
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return AppColor.colorCanceledEventActionText;
      case EventMethod.reply:
        final matchedAttendee = findAttendeeHasUpdatedStatus(senderEmailAddress);
        if (matchedAttendee != null) {
          return getAttendeeMessageTextColor(matchedAttendee.participationStatus);
        } else {
          return Colors.transparent;
        }
      default:
        return Colors.transparent;
    }
  }

  String getIconEventAction(ImagePaths imagePaths) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return imagePaths.icEventInvited;
      case EventMethod.refresh:
        return imagePaths.icEventUpdated;
      case EventMethod.cancel:
        return imagePaths.icEventCanceled;
      default:
        return '';
    }
  }

  String getTitleEventAction(BuildContext context, String senderEmailAddress) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerInvited;
      case EventMethod.refresh:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerUpdated;
      case EventMethod.cancel:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerCanceled;
      case EventMethod.reply:
        final matchedAttendee = findAttendeeHasUpdatedStatus(senderEmailAddress);
        if (matchedAttendee != null) {
          return getAttendeeMessageStatus(context, matchedAttendee.participationStatus);
        } else {
          return '';
        }
      case EventMethod.counter:
        return AppLocalizations.of(context).messageEventActionBannerAttendeeCounter;
      case EventMethod.declineCounter:
        return AppLocalizations.of(context).messageEventActionBannerAttendeeCounterDeclined;
      default:
        return '';
    }
  }

  String getSubTitleEventAction(BuildContext context) {
    switch(method) {
      case EventMethod.refresh:
        return AppLocalizations.of(context).subMessageEventActionBannerUpdated;
      case EventMethod.cancel:
        return AppLocalizations.of(context).subMessageEventActionBannerCanceled;
      default:
        return '';
    }
  }

  String getUserNameEventAction({
    required BuildContext context,
    required ImagePaths imagePaths,
    required String senderEmailAddress
  }) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
      case EventMethod.refresh:
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return getOrganizerName(context);
      case EventMethod.reply:
      case EventMethod.counter:
        return getAttendeeName(context, senderEmailAddress);
      default:
        return '';
    }
  }

  String getOrganizerName(BuildContext context) => organizer?.name ?? AppLocalizations.of(context).you;

  String getAttendeeName(BuildContext context, String senderEmailAddress) {
    final matchedAttendee = findAttendeeHasUpdatedStatus(senderEmailAddress);
    if (matchedAttendee != null) {
      return matchedAttendee.name?.name ?? AppLocalizations.of(context).anAttendee;
    } else {
      return AppLocalizations.of(context).anAttendee;
    }
  }

  CalendarAttendee? findAttendeeHasUpdatedStatus(String senderEmailAddress) {
    if (participants?.isNotEmpty == true) {
      final listMatchedAttendee = participants
        !.where((attendee) => attendee.mailto?.mailAddress.value == senderEmailAddress)
        .whereNotNull();
      log('CalendarEventExtension::findAttendeeHasUpdatedStatus:listMatchedAttendee: $listMatchedAttendee');
      if (listMatchedAttendee.isNotEmpty) {
        return listMatchedAttendee.first;
      }
    }
    return null;
  }

  String getAttendeeMessageStatus(BuildContext context, CalendarAttendeeParticipationStatus? status) {
    if (status == CalendarAttendeeParticipationStatus('ACCEPTED')) {
      return AppLocalizations.of(context).messageEventActionBannerAttendeeAccepted;
    } else if (status == CalendarAttendeeParticipationStatus('TENTATIVE')) {
      return AppLocalizations.of(context).messageEventActionBannerAttendeeTentative;
    } else if (status == CalendarAttendeeParticipationStatus('DECLINED')) {
      return AppLocalizations.of(context).messageEventActionBannerAttendeeDeclined;
    } else {
      return '';
    }
  }

  Color getAttendeeMessageTextColor(CalendarAttendeeParticipationStatus? status) {
    if (status == CalendarAttendeeParticipationStatus('ACCEPTED')) {
      return AppColor.colorUpdatedEventActionText;
    } else if (status == CalendarAttendeeParticipationStatus('TENTATIVE')) {
      return AppColor.colorMaybeEventActionText;
    } else if (status == CalendarAttendeeParticipationStatus('DECLINED')) {
      return AppColor.colorCanceledEventActionText;
    } else {
      return Colors.transparent;
    }
  }
}