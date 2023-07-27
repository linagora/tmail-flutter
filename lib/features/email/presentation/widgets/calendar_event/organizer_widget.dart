
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attendee_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class OrganizerWidget extends StatelessWidget {

  final CalendarOrganizer organizer;

  const OrganizerWidget({
    super.key,
    required this.organizer
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: AttendeeWidgetStyles.textSize,
          fontWeight: FontWeight.w500,
          color: Colors.black
        ),
        children: [
          if (organizer.name?.isNotEmpty == true)
            TextSpan(text: organizer.name!),
          if (organizer.mailto?.value.isNotEmpty == true)
            TextSpan(
              text: ' <${organizer.mailto!.value}> ',
              style: const TextStyle(
                color: AppColor.colorMailto,
                fontSize: AttendeeWidgetStyles.textSize,
                fontWeight: FontWeight.w500
              ),
            ),
          TextSpan(text: '(${AppLocalizations.of(context).organizer})'),
          const TextSpan(text: ', '),
        ]
      )
    );
  }
}