
import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_participation_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

extension CalendarEventExtension on CalendarEvent {

  Color getColorEventActionBanner(List<String> listEmailAddressSender) {
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
        final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
        if (matchedAttendee != null) {
          return getAttendeeMessageTextColor(matchedAttendee.participationStatus);
        } else {
          return Colors.transparent;
        }
      default:
        return Colors.transparent;
    }
  }

  Color getColorEventActionText(List<String> listEmailAddressSender) {
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
        final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
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

  String getTitleEventAction(BuildContext context, List<String> listEmailAddressSender) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerInvited;
      case EventMethod.refresh:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerUpdated;
      case EventMethod.cancel:
        return AppLocalizations.of(context).messageEventActionBannerOrganizerCanceled;
      case EventMethod.reply:
        final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
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
    required List<String> listEmailAddressSender
  }) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
      case EventMethod.refresh:
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return getOrganizerNameEvent(context);
      case EventMethod.reply:
      case EventMethod.counter:
        return getAttendeeNameEvent(context, listEmailAddressSender);
      default:
        return '';
    }
  }

  String getOrganizerNameEvent(BuildContext context) => organizer?.name ?? AppLocalizations.of(context).you;

  String get organizerName => organizer?.name ?? organizer?.mailto?.value ?? '';

  String getAttendeeNameEvent(BuildContext context, List<String> listEmailAddressSender) {
    final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
    if (matchedAttendee != null) {
      return matchedAttendee.name?.name ?? AppLocalizations.of(context).anAttendee;
    } else {
      return AppLocalizations.of(context).anAttendee;
    }
  }

  CalendarAttendee? findAttendeeHasUpdatedStatus(List<String> listEmailAddressSender) {
    if (participants?.isNotEmpty == true) {
      final listMatchedAttendee = participants
        !.where((attendee) => attendee.mailto != null && listEmailAddressSender.contains(attendee.mailto!.mailAddress.value))
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

  DateTime? get localStartDate => startUtcDate?.value.toLocal();

  DateTime? get localEndDate => endUtcDate?.value.toLocal();

  String get monthStartDateAsString {
    if (localStartDate != null) {
      return date_format.formatDate(
        localStartDate!,
        [date_format.M],
        locale: AppUtils.getCurrentDateLocale()
      );
    } else {
      return '';
    }
  }

  String get dayStartDateAsString {
    if (localStartDate != null) {
      return date_format.formatDate(
        localStartDate!,
        [date_format.d],
        locale: AppUtils.getCurrentDateLocale()
      );
    } else {
      return '';
    }
  }

  String get weekDayStartDateAsString {
    if (localStartDate != null) {
      return date_format.formatDate(
        localStartDate!,
        [date_format.D],
        locale: AppUtils.getCurrentDateLocale()
      );
    } else {
      return '';
    }
  }

  String formatDateTime(DateTime dateTime) {
    return date_format.formatDate(
      dateTime,
      [
        date_format.DD,
        ', ',
        date_format.MM,
        ' ',
        date_format.dd,
        ', ',
        date_format.yyyy,
        ' ',
        date_format.hh,
        ':',
        date_format.ss,
        ' ',
        date_format.am
      ],
      locale: AppUtils.getCurrentDateLocale()
    );
  }

  String formatTime(DateTime dateTime) {
    return date_format.formatDate(
      dateTime,
      [
        date_format.hh,
        ':',
        date_format.ss,
        ' ',
        date_format.am
      ],
      locale: AppUtils.getCurrentDateLocale()
    );
  }

  String formatDate(date_format.DateLocale locale, DateTime dateTime) {
    return date_format.formatDate(
      dateTime,
      [
        date_format.DD,
        ', ',
        date_format.MM,
        ' ',
        date_format.dd,
        ', ',
        date_format.yyyy
      ],
      locale: locale
    );
  }

  bool get isAllDayEvent {
    if (startUtcDate != null && endUtcDate != null) {
      final startDateValue = startUtcDate!.value;
      final endDateValue = endUtcDate!.value;

      final eventDurationInHours = startDateValue.difference(endDateValue).inHours;

      final startHour = startDateValue.hour;
      final startMinute = startDateValue.minute;
      final startSecond = startDateValue.second;
      
      final endHour = endDateValue.hour;
      final endMinute = endDateValue.minute;
      final endSecond = endDateValue.second;

      return startHour == 0 
        && startMinute == 0
        && startSecond == 0
        && endHour == 0
        && endMinute == 0
        && endSecond == 0
        && eventDurationInHours % 24 == 0;
    }
    return false;
  }

  String dateTimeStringForAllDayEvent(DateTime startDate, DateTime endDate) {
    final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    final timeZoneOffsetAsString = timeZoneOffset >= 0 ? '+$timeZoneOffset' : '$timeZoneOffset';

    final dateStart = formatDate(AppUtils.getCurrentDateLocale(), startDate);

    final endDateToDisplay = endDate.subtract(const Duration(days: 1));
    final dateEnd = formatDate(AppUtils.getCurrentDateLocale(), endDateToDisplay);

    if (DateUtils.isSameDay(startDate, endDateToDisplay)) {
      return '$dateStart (GMT$timeZoneOffsetAsString)';
    } else {
      return '$dateStart - $dateEnd (GMT$timeZoneOffsetAsString)';
    }
  }

  String get dateTimeEventAsString {
    if (isAllDayEvent) {
      return dateTimeStringForAllDayEvent(startUtcDate!.value, endUtcDate!.value);
    }

    if (localStartDate != null && localEndDate != null) {
      final timeStart = formatDateTime(localStartDate!);
      final timeEnd = DateUtils.isSameDay(localStartDate, localEndDate)
        ? formatTime(localEndDate!)
        : formatDateTime(localEndDate!);
      return '$timeStart - $timeEnd';
    } else if (localStartDate != null) {
      return formatDateTime(localStartDate!);
    } else if (localEndDate != null) {
      return formatDateTime(localEndDate!);
    } else {
      return '';
    }
  }

  List<String> get videoConferences {
    if (extensionFields != null && extensionFields!.mapFields.isNotEmpty) {
      final videoConferences = List<String>.empty(growable: true);

      final openPaasVideoConferences = extensionFields?.mapFields['X-OPENPAAS-VIDEOCONFERENCE']
        ?.whereNotNull()
        .where((link) => link.isNotEmpty)
        .toList() ?? [];
      log('CalendarEventExtension::openPaasVideoConferences: $openPaasVideoConferences');
      final googleVideoConferences = extensionFields!.mapFields['X-GOOGLE-CONFERENCE']
        ?.whereNotNull()
        .where((link) => link.isNotEmpty)
        .toList() ?? [];
      log('CalendarEventExtension::googleVideoConferences: $googleVideoConferences');
      if (openPaasVideoConferences.isNotEmpty) {
        videoConferences.addAll(openPaasVideoConferences);
      }
      if (googleVideoConferences.isNotEmpty) {
        videoConferences.addAll(googleVideoConferences);
      }
      return videoConferences;
    }
    return [];
  }
}