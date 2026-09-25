import 'package:collection/collection.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_organier_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/list_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/extensions/calendar_url_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Display-specific inputs used while mapping an event card.
class CalendarEventCardMappingOptions {
  final AppLocalizations appLocalizations;
  final date_format.DateLocale dateLocale;
  final String timeZone;
  final String? calendarUrlTemplate;

  const CalendarEventCardMappingOptions({
    required this.appLocalizations,
    required this.dateLocale,
    required this.timeZone,
    this.calendarUrlTemplate,
  });
}

/// Turns a [CalendarEvent] into the data an invitation card renders.
///
/// Every section is derived independently and returns null when the event
/// carries nothing for it, so an event with no location, no attendees, no
/// conference link, or no invitation to answer simply drops those sections.
class CalendarEventCardMapper {
  final CalendarEvent event;
  final CalendarEventCardViewState viewState;
  final CalendarEventCardActions actions;
  final CalendarEventCardMappingOptions options;

  AppLocalizations get appLocalizations => options.appLocalizations;
  date_format.DateLocale get dateLocale => options.dateLocale;
  String get timeZone => options.timeZone;

  const CalendarEventCardMapper({
    required this.event,
    required this.viewState,
    required this.actions,
    required this.options,
  });

  LinagoraEventCardData get cardData {
    final conferences = this.conferences;

    return LinagoraEventCardData(
      date: date,
      activity: hasActivity ? activity : null,
      actorName: hasActivity ? actorName : null,
      activityState: activityState,
      title: title,
      conference: conferences.firstOrNull,
      additionalConferences: conferences.skip(1).toList(),
      details: details,
      attending: attending,
      actions: cardActions,
      status: status,
      calendarAction: calendarAction,
    );
  }

  /// The date marker, or null when the localised date cannot fill it.
  ///
  /// The marker holds a localised, non-blank month and a one- or two-digit day.
  LinagoraEventDate? get date {
    final month = event.monthStartDateAsString(dateLocale);
    final day = event.dayStartDateAsString(dateLocale);

    final invalid = LinagoraEventDateIcon.validateDateParts(
      month: month,
      day: day,
    );
    if (invalid != null) return null;

    return LinagoraEventDate(month: month, day: day);
  }

  String? get title => event.title;

  /// Who the activity line is about, shown in bold before it.
  String get actorName => event.getUserNameEventAction(
    appLocalizations: appLocalizations,
    listEmailAddressSender: viewState.listEmailAddressSender,
  );

  /// What happened to the event, such as being invited to it.
  String get activity => event.getTitleEventAction(
    appLocalizations,
    viewState.listEmailAddressSender,
  );

  /// The badge needs both halves of its sentence to read, so an event whose
  /// method resolves neither shows none.
  bool get hasActivity => actorName.isNotEmpty && activity.isNotEmpty;

  EventActivityBadgeState get activityState {
    switch (event.method) {
      case EventMethod.request:
      case EventMethod.add:
        return EventActivityBadgeState.created;
      case EventMethod.refresh:
      case EventMethod.counter:
        return EventActivityBadgeState.updated;
      case EventMethod.cancel:
      case EventMethod.declineCounter:
        return EventActivityBadgeState.canceled;
      case EventMethod.reply:
        return _replyActivityState;
      default:
        return EventActivityBadgeState.created;
    }
  }

  EventActivityBadgeState get _replyActivityState {
    final status = event
        .findAttendeeHasUpdatedStatus(viewState.listEmailAddressSender)
        ?.participationStatus
        ?.value;

    return switch (status) {
      CalendarEventExtension.acceptedParticipationStatus =>
        EventActivityBadgeState.accepted,
      CalendarEventExtension.tentativeParticipationStatus =>
        EventActivityBadgeState.maybe,
      CalendarEventExtension.declinedParticipationStatus =>
        EventActivityBadgeState.canceled,
      _ => EventActivityBadgeState.created,
    };
  }

  /// Conference controls for every link the event carries.
  List<LinagoraEventConference> get conferences {
    final links = event.videoConferences
        .where((link) => link.trim().isNotEmpty)
        .toList();

    return [
      for (var index = 0; index < links.length; index++)
        _conference(
          links[index],
          label: index == 0
              ? appLocalizations.joinTheVideoConference
              : links[index],
        ),
    ];
  }

  LinagoraEventConference _conference(String link, {required String label}) {
    final onOpenLink = actions.onOpenLink;
    final onCopyLink = actions.onCopyLink;

    return LinagoraEventConference.fromLink(
      link: link,
      label: label,
      onOpenLink: onOpenLink,
      onCopyLink: onCopyLink,
      copyTooltip: appLocalizations.copyLink,
      copySemanticLabel: appLocalizations.copyLink,
    );
  }

  List<LinagoraEventDetail> get details {
    return [_whenDetail, _whereDetail, _whoDetail].nonNulls.toList();
  }

  LinagoraEventDetail? get _whenDetail {
    final dateTime = event.getDateTimeParts(
      dateLocale: dateLocale,
      timeZone: timeZone,
    );
    if (dateTime.isEmpty) return null;

    return LinagoraEventDetail.when(
      label: appLocalizations.when,
      dateTime: dateTime,
      indicator: viewState.hasScheduleConflict
          ? LinagoraEventConflictIndicator(
              message:
                  appLocalizations.youHaveAnotherEventAtThatSameTime,
            )
          : null,
    );
  }

  LinagoraEventDetail? get _whereDetail {
    final location = event.location;
    if (location == null || location.trim().isEmpty) return null;

    return LinagoraEventDetail(
      label: appLocalizations.where,
      values: _locationValues(location),
      valueSpacing: 0,
    );
  }

  /// Splits the location so its URLs and email addresses stay reachable,
  /// leaving the surrounding text plain.
  List<LinagoraEventValue> _locationValues(String location) {
    return LinagoraEventTextValues.fromText(
      location,
      onOpenLink: actions.onOpenLink,
      onOpenEmail: actions.onOpenComposer,
    );
  }

  LinagoraEventDetail? get _whoDetail {
    final organizer = event.organizer == null
        ? null
        : _organizer(event.organizer!);
    final attendees = _attendees
        .map(_attendee)
        .where((attendee) => !attendee.isEmpty)
        .toList();
    final organizerIsEmpty = organizer == null || organizer.isEmpty;
    if (organizerIsEmpty && attendees.isEmpty) {
      return null;
    }
    final collapsedAttendeeCount = organizerIsEmpty ? 1 : 0;

    return LinagoraEventDetail.participants(
      labels: LinagoraEventParticipantLabels(
        label: appLocalizations.who,
        organizerLabel: appLocalizations.organizer,
      ),
      organizer: organizer,
      attendees: attendees,
      expansion: LinagoraEventDetailExpansion(
        expandLabel: appLocalizations.seeAllAttendees,
        collapseLabel: appLocalizations.hide,
        collapsedLineCount: collapsedAttendeeCount,
        collapseThreshold: collapsedAttendeeCount,
        identity: event,
      ),
    );
  }

  LinagoraEventParticipant _organizer(CalendarOrganizer organizer) {
    final name = _nonBlank(organizer.name);
    final address = _nonBlank(organizer.mailto?.value);
    final onOpenEmailAddress = actions.onOpenEmailAddress;

    return LinagoraEventParticipant(
      name: name,
      address: address,
      onAddressTap: address?.isNotEmpty == true && onOpenEmailAddress != null
          ? () => onOpenEmailAddress(organizer.toEmailAddress())
          : null,
    );
  }

  LinagoraEventParticipant _attendee(CalendarAttendee attendee) {
    final name = _nonBlank(attendee.name?.name);
    final address = _nonBlank(attendee.mailto?.mailAddress.value);
    final onOpenEmailAddress = actions.onOpenEmailAddress;

    return LinagoraEventParticipant(
      name: name,
      address: address,
      onAddressTap: address?.isNotEmpty == true && onOpenEmailAddress != null
          ? () => onOpenEmailAddress(attendee.toEmailAddress())
          : null,
    );
  }

  List<CalendarAttendee> get _attendees =>
      event.participants?.withoutOrganizer(event.organizer) ?? [];

  String? _nonBlank(String? value) =>
      value?.trim().isNotEmpty == true ? value : null;

  List<EventActionType> get _eventActionTypes =>
      event.getEventActionTypesIsDisplayed(viewState.ownEmailAddress);

  /// The mutually exclusive answers to the invitation.
  LinagoraEventAttending? get attending {
    final responses = [
      for (final actionType in _eventActionTypes)
        if (actionType != EventActionType.mailToAttendees)
          _responseAction(actionType),
    ];
    if (responses.isEmpty) return null;

    return LinagoraEventAttending(
      label: appLocalizations.attending,
      responses: responses,
      selectedResponseId: _selectedResponseActionType,
    );
  }

  LinagoraEventAction _responseAction(EventActionType actionType) {
    final isReplyDisabled = viewState.replying &&
        actionType != EventActionType.acceptCounter;
    final isSelected = actionType == _selectedResponseActionType;

    return LinagoraEventAction(
      id: actionType,
      label: actionType.getLabelButton(appLocalizations),
      onPressed: isReplyDisabled || isSelected
          ? null
          : () => actions.onReply(actionType),
    );
  }

  EventActionType? get _selectedResponseActionType {
    if (_eventActionTypes.contains(EventActionType.acceptCounter)) return null;

    return switch (viewState.attendanceStatus) {
      AttendanceStatus.accepted => EventActionType.yes,
      AttendanceStatus.tentativelyAccepted => EventActionType.maybe,
      AttendanceStatus.rejected => EventActionType.no,
      _ => null,
    };
  }

  /// Actions that carry no answer, such as writing to everyone invited.
  List<LinagoraEventAction> get cardActions {
    return [
      for (final actionType in _eventActionTypes)
        if (actionType == EventActionType.mailToAttendees)
          LinagoraEventAction(
            label: actionType.getLabelButton(appLocalizations),
            onPressed: actions.onMailToAttendees,
          ),
    ];
  }

  LinagoraEventAction? get calendarAction {
    if (event.isDisplayedWarningMessage(viewState.ownEmailAddress)) return null;

    final eventUrl = options.calendarUrlTemplate.resolveCalendarEventUrl(
      event.eventId?.id,
      ownerEmail: viewState.ownEmailAddress,
    );
    final onOpenLink = actions.onOpenLink;
    if (eventUrl == null || onOpenLink == null) return null;

    return LinagoraEventAction.calendar(
      id: eventUrl,
      label: appLocalizations.seeInYourCalendar,
      onPressed: () => onOpenLink(eventUrl.toString()),
    );
  }

  LinagoraEventStatus? get status {
    if (!event.isDisplayedWarningMessage(viewState.ownEmailAddress)) {
      return null;
    }

    return LinagoraEventStatus(
      appLocalizations.youAreNotInvitedToThisEventPleaseContactTheOrganizer,
    );
  }
}
