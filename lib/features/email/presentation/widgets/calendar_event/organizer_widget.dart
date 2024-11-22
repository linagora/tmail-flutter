
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_organier_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/organizer_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class OrganizerWidget extends StatelessWidget {

  final CalendarOrganizer organizer;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;

  const OrganizerWidget({
    super.key,
    required this.organizer,
    this.openEmailAddressDetailAction,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: OrganizerWidgetStyles.textSize,
          fontWeight: FontWeight.w500,
          color: OrganizerWidgetStyles.textColor
        ),
        children: [
          if (organizer.name?.isNotEmpty == true)
            TextSpan(text: organizer.name!),
          if (organizer.mailto?.value.isNotEmpty == true)
            TextSpan(
              text: ' <${organizer.mailto!.value}> ',
              style: const TextStyle(
                color: OrganizerWidgetStyles.mailtoColor,
                fontSize: OrganizerWidgetStyles.textSize,
                fontWeight: FontWeight.w500
              ),
              recognizer: TapGestureRecognizer()..onTap = () => _onClickMailAddress(context)
            ),
          TextSpan(text: '(${AppLocalizations.of(context).organizer})'),
          const TextSpan(text: ', '),
        ]
      )
    );
  }

  void _onClickMailAddress(BuildContext context) {
    openEmailAddressDetailAction?.call(context, organizer.toEmailAddress());
  }
}