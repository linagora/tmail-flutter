import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/presentation/mapper/calendar_event_card_mapper.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_card_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

/// The invitation card for a calendar event carried by an email.
///
/// Tmail maps its JMAP event and actions while the design system owns the
/// card's presentation-only interactions.
class CalendarEventCardWidget extends StatelessWidget {
  final CalendarEvent calendarEvent;
  final CalendarEventCardViewState viewState;
  final CalendarEventCardActions actions;
  final LinagoraEventCardLayout layout;
  final String? calendarUrl;

  const CalendarEventCardWidget({
    super.key,
    required this.calendarEvent,
    required this.viewState,
    required this.actions,
    this.layout = LinagoraEventCardLayout.adaptive,
    this.calendarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final mapper = CalendarEventCardMapper(
      event: calendarEvent,
      viewState: viewState,
      actions: actions,
      options: CalendarEventCardMappingOptions(
        appLocalizations: AppLocalizations.of(context),
        dateLocale: AppUtils.getCurrentDateLocale(),
        timeZone: AppUtils.getTimeZone(),
        calendarUrl: calendarUrl,
      ),
    );

    return Padding(
      padding: CalendarEventCardWidgetStyles.margin,
      child: LinagoraEventCard.fromData(
        mapper.cardData,
        layout: layout,
      ),
    );
  }
}
