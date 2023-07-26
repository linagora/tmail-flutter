
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/list_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_attendee_information_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventAttendeeInformationWidget extends StatelessWidget {

  final List<CalendarAttendee> attendees;
  final CalendarOrganizer organizer;

  const EventAttendeeInformationWidget({
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
          width: EventAttendeeInformationWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).who,
            style: const TextStyle(
              fontSize: EventAttendeeInformationWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: AppColor.colorSubTitleEventActionText
            ),
          ),
        ),
        Expanded(child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: EventAttendeeInformationWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: Colors.black
            ),
            children: [
              TextSpan(
                text: '${organizer.mailto?.value} (${AppLocalizations.of(context).organizer})',
                style: const TextStyle(
                  color: AppColor.colorOrganizerMailto,
                  fontSize: EventAttendeeInformationWidgetStyles.textSize,
                  fontWeight: FontWeight.w500
                ),
              ),
              const TextSpan(text: ', '),
              TextSpan(text: attendees.withoutOrganizer(organizer).mailtoAsString)
            ]
          )
        ))
      ],
    );
  }
}