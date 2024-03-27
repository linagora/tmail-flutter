
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attendee_widget_styles.dart';

class AttendeeWidget extends StatelessWidget {

  final CalendarAttendee attendee;
  final List<CalendarAttendee> listAttendees;

  const AttendeeWidget({
    super.key,
    required this.attendee,
    required this.listAttendees,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: AttendeeWidgetStyles.textSize,
          fontWeight: FontWeight.w500,
          color: AttendeeWidgetStyles.textColor
        ),
        children: [
          if (attendee.name?.name.isNotEmpty == true)
            TextSpan(text: attendee.name!.name),
          if (attendee.mailto?.mailAddress.value.isNotEmpty == true)
            TextSpan(
              text: ' <${attendee.mailto!.mailAddress.value}> ',
              style: const TextStyle(
                color: AttendeeWidgetStyles.mailtoColor,
                fontSize: AttendeeWidgetStyles.textSize,
                fontWeight: FontWeight.w500
              ),
            ),
          if (listAttendees.last != attendee)
            const TextSpan(text: ', '),
        ]
      )
    );
  }
}