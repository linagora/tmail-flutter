
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_participation_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_duration.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_event_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_extension_fields.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_free_busy_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_priority.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_privacy.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_sequence.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/recurrence_rule/recurrence_rule.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension CalendarEventExtension on CalendarEvent {

  static const String acceptedParticipationStatus = 'ACCEPTED';
  static const String tentativeParticipationStatus = 'TENTATIVE';
  static const String declinedParticipationStatus = 'DECLINED';

  String getTitleEventAction(
    AppLocalizations appLocalizations,
    List<String> listEmailAddressSender,
  ) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
        return appLocalizations.messageEventActionBannerOrganizerInvited;
      case EventMethod.refresh:
        return appLocalizations.messageEventActionBannerOrganizerUpdated;
      case EventMethod.cancel:
        return appLocalizations.messageEventActionBannerOrganizerCanceled;
      case EventMethod.reply:
        final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
        if (matchedAttendee != null) {
          return getAttendeeMessageStatus(appLocalizations, matchedAttendee.participationStatus);
        } else {
          return '';
        }
      case EventMethod.counter:
        return appLocalizations.messageEventActionBannerAttendeeCounter;
      case EventMethod.declineCounter:
        return appLocalizations.messageEventActionBannerAttendeeCounterDeclined;
      default:
        return '';
    }
  }

  String getUserNameEventAction({
    required AppLocalizations appLocalizations,
    required List<String> listEmailAddressSender,
  }) {
    switch(method) {
      case EventMethod.request:
      case EventMethod.add:
      case EventMethod.refresh:
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return organizerName;
      case EventMethod.reply:
      case EventMethod.counter:
        return getAttendeeNameEvent(appLocalizations, listEmailAddressSender);
      default:
        return '';
    }
  }

  String get organizerName => organizer?.name ?? organizer?.mailto?.value ?? '';

  String getAttendeeNameEvent(
    AppLocalizations appLocalizations,
    List<String> listEmailAddressSender,
  ) {
    final matchedAttendee = findAttendeeHasUpdatedStatus(listEmailAddressSender);
    if (matchedAttendee != null) {
      return matchedAttendee.name?.name ?? appLocalizations.anAttendee;
    } else {
      return appLocalizations.anAttendee;
    }
  }

  CalendarAttendee? findAttendeeHasUpdatedStatus(List<String> listEmailAddressSender) {
    if (participants?.isNotEmpty == true) {
      final listMatchedAttendee = participants
        !.where((attendee) => attendee.mailto != null && listEmailAddressSender.contains(attendee.mailto!.mailAddress.value))
        .nonNulls;
      log('CalendarEventExtension::findAttendeeHasUpdatedStatus:listMatchedAttendee: $listMatchedAttendee');
      if (listMatchedAttendee.isNotEmpty) {
        return listMatchedAttendee.first;
      }
    }
    return null;
  }

  String getAttendeeMessageStatus(
    AppLocalizations appLocalizations,
    CalendarAttendeeParticipationStatus? status,
  ) {
    if (status == CalendarAttendeeParticipationStatus(acceptedParticipationStatus)) {
      return appLocalizations.messageEventActionBannerAttendeeAccepted;
    } else if (status == CalendarAttendeeParticipationStatus(tentativeParticipationStatus)) {
      return appLocalizations.messageEventActionBannerAttendeeTentative;
    } else if (status == CalendarAttendeeParticipationStatus(declinedParticipationStatus)) {
      return appLocalizations.messageEventActionBannerAttendeeDeclined;
    } else {
      return '';
    }
  }

  DateTime? get localStartDate => startUtcDate?.value.toLocal();

  DateTime? get localEndDate => endUtcDate?.value.toLocal();

  String monthStartDateAsString(date_format.DateLocale dateLocale) {
    final startDate = localStartDate;
    if (startDate == null) return '';

    return date_format.formatDate(
      startDate,
      [date_format.M],
      locale: dateLocale,
    );
  }

  String dayStartDateAsString(date_format.DateLocale dateLocale) {
    final startDate = localStartDate;
    if (startDate == null) return '';

    return date_format.formatDate(
      startDate,
      [date_format.d],
      locale: dateLocale,
    );
  }

  String formatDateTime(date_format.DateLocale locale, DateTime dateTime) {
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
        date_format.nn,
        ' ',
        date_format.am
      ],
      locale: locale
    );
  }

  String formatTime(date_format.DateLocale locale, DateTime dateTime) {
    return date_format.formatDate(
      dateTime,
      [
        date_format.hh,
        ':',
        date_format.nn,
        ' ',
        date_format.am
      ],
      locale: locale
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

  String dateTimeStringForAllDayEvent({
    required DateTime startDate,
    required DateTime endDate,
    required date_format.DateLocale dateLocale,
    required String timeZone
  }) {
    final dateStart = formatDate(dateLocale, startDate);
    final endDateToDisplay = endDate.subtract(const Duration(days: 1));
    final dateEnd = formatDate(dateLocale, endDateToDisplay);

    if (DateUtils.isSameDay(startDate, endDateToDisplay)) {
      return '$dateStart ($timeZone)';
    } else {
      return '$dateStart - $dateEnd ($timeZone)';
    }
  }

  String getDateTimeEvent({
    required date_format.DateLocale dateLocale,
    required String timeZone
  }) {
    return getDateTimeParts(
      dateLocale: dateLocale,
      timeZone: timeZone,
    ).joined;
  }

  /// The `When` line with its day separated from its clock time, so each half
  /// can be presented on its own.
  ///
  /// A line the day and the time cannot be split cleanly out of — an all-day
  /// event, or a range spanning several days — stays whole in
  /// [LinagoraEventDateTime.date].
  LinagoraEventDateTime getDateTimeParts({
    required date_format.DateLocale dateLocale,
    required String timeZone
  }) {
    if (isAllDayEvent) {
      return LinagoraEventDateTime(
        date: dateTimeStringForAllDayEvent(
          startDate: startUtcDate!.value,
          endDate: endUtcDate!.value,
          dateLocale: dateLocale,
          timeZone: timeZone,
        ),
      );
    }

    final startDate = localStartDate;
    final endDate = localEndDate;

    if (startDate != null && endDate != null) {
      if (!DateUtils.isSameDay(startDate, endDate)) {
        final timeStart = formatDateTime(dateLocale, startDate);
        final timeEnd = formatDateTime(dateLocale, endDate);
        return LinagoraEventDateTime(date: '$timeStart - $timeEnd');
      }

      return LinagoraEventDateTime(
        date: formatDate(dateLocale, startDate),
        time: '${formatTime(dateLocale, startDate)}'
            ' - ${formatTime(dateLocale, endDate)}',
      );
    }

    final singleDate = startDate ?? endDate;
    if (singleDate == null) return LinagoraEventDateTime.empty;

    return LinagoraEventDateTime(
      date: formatDate(dateLocale, singleDate),
      time: formatTime(dateLocale, singleDate),
    );
  }

  List<String> get videoConferences {
    if (extensionFields != null && extensionFields!.mapFields.isNotEmpty) {
      final videoConferences = List<String>.empty(growable: true);

      final openPaasVideoConferences = extensionFields?.mapFields['X-OPENPAAS-VIDEOCONFERENCE']
        ?.nonNulls
        .where((link) => link.isNotEmpty)
        .toList() ?? [];
      log('CalendarEventExtension::openPaasVideoConferences: $openPaasVideoConferences');
      final googleVideoConferences = extensionFields!.mapFields['X-GOOGLE-CONFERENCE']
        ?.nonNulls
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

  bool isDisplayedEventReplyAction(String ownerEmailAddress) =>
      method != null &&
      _methodIsRepliable &&
      organizer != null &&
      participants?.isNotEmpty == true &&
      userIsListedInParticipants(ownerEmailAddress);

  bool get _methodIsRepliable => 
    method == EventMethod.request ||
    method == EventMethod.add ||
    method == EventMethod.counter;

  bool userIsListedInParticipants(String ownEmailAddress) {
    final participant = participants?.firstWhereOrNull((participant) =>
    participant.mailto?.mailAddress.value == ownEmailAddress);
    return participant != null;
  }

  bool userIsOrganizer(String ownEmailAddress) {
    return organizer?.mailto?.value == ownEmailAddress;
  }

  bool isDisplayedWarningMessage(String ownerEmailAddress) {
    return !userIsListedInParticipants(ownerEmailAddress) &&
      !userIsOrganizer(ownerEmailAddress);
  }

  bool get isDisplayedMailToAttendees =>
      organizer != null || participants?.isNotEmpty == true;

  List<EventActionType> getEventActionTypesIsDisplayed(
    String ownerEmailAddress,
  ) {
    if (isDisplayedEventReplyAction(ownerEmailAddress)) {
      return [
        if (method == EventMethod.counter)
          EventActionType.acceptCounter
        else
          ...[
            EventActionType.yes,
            EventActionType.maybe,
            EventActionType.no,
          ],
        EventActionType.mailToAttendees,
      ];
    } else if (isDisplayedMailToAttendees) {
      return [
        EventActionType.mailToAttendees,
      ];
    } else {
      return [];
    }
  }

  bool isIMIPResponsesAvailable(List<String> listEmailAddressSender) {
    final participationStatus = findAttendeeHasUpdatedStatus(
      listEmailAddressSender,
    )?.participationStatus?.value;

    return method == EventMethod.reply &&
        (participationStatus == acceptedParticipationStatus ||
            participationStatus == tentativeParticipationStatus ||
            participationStatus == declinedParticipationStatus);
  }

  CalendarEvent copyWith({
    EventId? eventId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    UTCDate? startUtcDate,
    UTCDate? endUtcDate,
    CalendarDuration? duration,
    String? timeZone,
    String? location,
    EventMethod? method,
    CalendarSequence? sequence,
    CalendarPrivacy? privacy,
    CalendarPriority? priority,
    CalendarFreeBusyStatus? freeBusyStatus,
    CalendarEventStatus? status,
    CalendarOrganizer? organizer,
    List<CalendarAttendee>? participants,
    CalendarExtensionFields? extensionFields,
    List<RecurrenceRule>? recurrenceRules,
    List<RecurrenceRule>? excludedCalendarEvents,
  }) {
    return CalendarEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startUtcDate: startUtcDate ?? this.startUtcDate,
      endUtcDate: endUtcDate ?? this.endUtcDate,
      duration: duration ?? this.duration,
      timeZone: timeZone ?? this.timeZone,
      location: location ?? this.location,
      method: method ?? this.method,
      sequence: sequence ?? this.sequence,
      privacy: privacy ?? this.privacy,
      priority: priority ?? this.priority,
      freeBusyStatus: freeBusyStatus ?? this.freeBusyStatus,
      status: status ?? this.status,
      organizer: organizer ?? this.organizer,
      participants: participants ?? this.participants,
      extensionFields: extensionFields ?? this.extensionFields,
      recurrenceRules: recurrenceRules ?? this.recurrenceRules,
      excludedCalendarEvents: excludedCalendarEvents ?? this.excludedCalendarEvents,
    );
  }

  String getMailToAttendeesEventTitle(AppLocalizations appLocalizations) {
    return EmailUtils.applyPrefix(
      subject: title ?? '',
      defaultPrefix: EmailUtils.defaultReplyPrefix,
      localizedPrefix: appLocalizations.prefix_reply_email,
    );
  }
}
