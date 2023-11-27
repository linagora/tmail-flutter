
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/calendar_event_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_attendee_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_body_content_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_description_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_link_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_time_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_title_widget.dart';

class CalendarEventDetailWidget extends StatelessWidget {

  final CalendarEvent calendarEvent;
  final List<EventAction> eventActions;
  final String emailContent;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;
  final bool? isDraggableAppActive;
  final OnMailtoDelegateAction? onMailtoDelegateAction;

  const CalendarEventDetailWidget({
    super.key,
    required this.calendarEvent,
    required this.eventActions,
    required this.emailContent,
    this.isDraggableAppActive,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
    this.onMailtoDelegateAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: CalendarEventDetailWidgetStyles.borderStrokeWidth,
            color: CalendarEventDetailWidgetStyles.borderStrokeColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(CalendarEventDetailWidgetStyles.borderRadius)),
        ),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: CalendarEventDetailWidgetStyles.verticalMargin,
        horizontal: CalendarEventDetailWidgetStyles.horizontalMargin),
      padding: const EdgeInsets.all(CalendarEventDetailWidgetStyles.contentPadding),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calendarEvent.title?.isNotEmpty == true)
            EventTitleWidget(title: calendarEvent.title!),
          if (calendarEvent.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventDescriptionDetailWidget(
                description: calendarEvent.description!,
                onOpenComposerAction: onOpenComposerAction,
                onOpenNewTabAction: onOpenNewTabAction,
              )
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventBodyContentWidget(
                content: emailContent,
                isDraggableAppActive: isDraggableAppActive,
                onMailtoDelegateAction: onMailtoDelegateAction,
              )
            ),
          if (calendarEvent.dateTimeEventAsString.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventTimeWidgetWidget(timeEvent: calendarEvent.dateTimeEventAsString),
            ),
          if (calendarEvent.videoConferences.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventLinkDetailWidget(listHyperLink: calendarEvent.videoConferences),
            ),
          if (calendarEvent.location?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventLocationDetailWidget(
                locationEvent: calendarEvent.location!,
                onOpenComposerAction: onOpenComposerAction,
                onOpenNewTabAction: onOpenNewTabAction,
              ),
            ),
          if (calendarEvent.participants?.isNotEmpty == true && calendarEvent.organizer != null)
            Padding(
              padding: const EdgeInsets.only(top: CalendarEventDetailWidgetStyles.fieldTopPadding),
              child: EventAttendeeDetailWidget(
                attendees: calendarEvent.participants!,
                organizer: calendarEvent.organizer!,
              ),
            ),
          if (eventActions.isNotEmpty)
            CalendarEventActionButtonWidget(eventActions: eventActions),
        ],
      ),
    );
  }
}
