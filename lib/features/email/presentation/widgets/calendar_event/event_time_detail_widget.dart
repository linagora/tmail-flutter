
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_time_detail_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventTimeWidgetWidget extends StatelessWidget {

  final String timeEvent;

  const EventTimeWidgetWidget({
    super.key,
    required this.timeEvent
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventTimeDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).time,
            style: const TextStyle(
              fontSize: EventTimeDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventTimeDetailWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Text(
          timeEvent,
          style: const TextStyle(
            fontSize: EventTimeDetailWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventTimeDetailWidgetStyles.valueColor
          ),
        ))
      ],
    );
  }
}