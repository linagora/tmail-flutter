
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/list_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_attendee_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/attendee_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventAttendeeDetailWidget extends StatelessWidget {

  static const int _maxAttendeeDisplayed = 5;

  final List<CalendarAttendee> attendees;
  final CalendarOrganizer organizer;

  const EventAttendeeDetailWidget({
    super.key,
    required this.attendees,
    required this.organizer
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventAttendeeDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).attendees,
            style: const TextStyle(
              fontSize: EventAttendeeDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: AppColor.colorSubTitleEventActionText
            ),
          ),
        ),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attendeeOrganizer != null)
              AttendeeWidget(attendee: attendeeOrganizer!, organizer: organizer),
            ..._attendeesDisplayed
                .map((attendee) => AttendeeWidget(attendee: attendee, organizer: organizer))
                .toList()
          ]
        ))
      ],
    );
  }

  CalendarAttendee? get attendeeOrganizer {
    try {
      return attendees.firstWhere((attendee) => attendee.mailto?.mailAddress == organizer.mailto);
    } catch (e) {
      return null;
    }
  }

  List<CalendarAttendee> get _attendeesDisplayed {
    final attendeesWithoutOrganizer = attendees.withoutOrganizer(organizer);
    return attendeesWithoutOrganizer.length > _maxAttendeeDisplayed
      ? attendeesWithoutOrganizer.sublist(0, _maxAttendeeDisplayed - 1)
      : attendeesWithoutOrganizer;
  }
}