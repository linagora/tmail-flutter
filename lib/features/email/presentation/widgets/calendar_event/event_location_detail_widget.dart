
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_location_detail_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventLocationDetailWidget extends StatelessWidget {

  final String locationEvent;

  const EventLocationDetailWidget({
    super.key,
    required this.locationEvent
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventLocationDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).location,
            style: const TextStyle(
              fontSize: EventLocationDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventLocationDetailWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Text(
          locationEvent,
          style: const TextStyle(
            fontSize: EventLocationDetailWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventLocationDetailWidgetStyles.valueColor
          ),
        ))
      ],
    );
  }
}