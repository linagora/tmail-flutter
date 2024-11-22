
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attendee_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';

class AttendeeWidget extends StatelessWidget {

  final CalendarAttendee attendee;
  final List<CalendarAttendee> listAttendees;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;

  const AttendeeWidget({
    super.key,
    required this.attendee,
    required this.listAttendees,
    this.openEmailAddressDetailAction,
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
              recognizer: TapGestureRecognizer()..onTap = () => _onClickMailAddress(context)
            ),
          if (listAttendees.last != attendee)
            const TextSpan(text: ', '),
        ]
      )
    );
  }

  void _onClickMailAddress(BuildContext context) {
    openEmailAddressDetailAction?.call(context, attendee.toEmailAddress());
  }
}